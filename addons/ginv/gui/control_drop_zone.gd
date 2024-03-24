@tool
class_name ControlDropZone extends Control

#region Signals
signal draggable_dropped(draggable, position)
#endregion

#region Private vars
var _mouse_inside: bool = false
static var _drop_event: Dictionary = {}
#endregion

#region Virtual functions
func _ready():
    mouse_entered.connect(func(): _mouse_inside = true)
    mouse_exited.connect(func(): _mouse_inside = false)

func _process(_delta):
    if _drop_event.is_empty():
        return
    elif !_drop_event.zone:
        ControlDraggable.release()
    elif _drop_event.zone != self:
        return
    else:
        _drop_event.zone.draggable_dropped.emit(ControlDraggable.get_grabbed_draggable(), get_drop_position())
        ControlDraggable.release_on(self)

    _drop_event = {}

func _input(event: InputEvent):
    if !event is InputEventMouseButton:
        return

    var mouse_button_event: InputEventMouseButton = event

    if mouse_button_event.is_pressed() || mouse_button_event.button_index != MOUSE_BUTTON_LEFT:
        return
    elif ControlDraggable.get_grabbed_draggable() == null:
        return
    elif _mouse_inside:
        _drop_event = {zone = self}
    elif _drop_event.is_empty():
        _drop_event = {zone = null}
#endregion

#region Public functions
func get_drop_position() -> Vector2:
    return get_local_mouse_position() - (ControlDraggable.get_grab_offset() / get_global_transform().get_scale())

func activate():
    mouse_filter = Control.MOUSE_FILTER_PASS

func deactivate():
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _mouse_inside = false

func is_active() -> bool:
    return (mouse_filter != Control.MOUSE_FILTER_IGNORE)
#endregion