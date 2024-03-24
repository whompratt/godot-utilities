@tool
class_name ControlDraggable extends Control

#region Signals
signal grabbed(position)
signal dropped(zone, position)

static var draggable_grabbed: Signal = (func():
    if (ControlDraggable as Object).has_user_signal("draggable_grabbed"):
        return (ControlDraggable as Object).draggable_grabbed
    (ControlDraggable as Object).add_user_signal("draggable_grabbed")
    return Signal(ControlDraggable, "draggable_grabbed")
).call()

static var draggable_dropped: Signal = (func():
    if (ControlDraggable as Object).has_user_signal("draggable_dropped"):
        return (ControlDraggable as Object).draggable_dropped
    (ControlDraggable as Object).add_user_signal("draggable_dropped")
    return Signal(ControlDraggable, "draggable_dropped")
).call()
#endregion

#region Constants
const EMBEDDED_WINDOWS_LAYER = 1024
#endregion

#region Public vars
var drag_preview: Control
var drag_z_index: int = 1
var enabled: bool = true
#endregion

#region Private vars
var _preview_canvas_layer: CanvasLayer = CanvasLayer.new()
static var _grabbed_draggable: ControlDraggable = null
static var _grab_offset: Vector2
#endregion

#region Public functions
static func grab(draggable: ControlDraggable):
    _grabbed_draggable = draggable
    _grab_offset = draggable.get_grab_position()

    draggable.mouse_filter = Control.MOUSE_FILTER_IGNORE
    draggable.grabbed.emit(_grab_offset)
    draggable_grabbed.emit(draggable, _grab_offset)
    draggable.drag_start()

static func release():
    _drop(null)

static func release_on(zone: ControlDropZone):
    _drop(zone)

static func get_grabbed_draggable() -> ControlDraggable:
    return _grabbed_draggable

static func get_grab_offset() -> Vector2:
    return _grab_offset

func get_grab_position() -> Vector2:
    return get_local_mouse_position() * get_global_transform().get_scale()

func drag_start():
    if !is_instance_valid(drag_preview):
        return

    drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
    drag_preview.global_position = _get_global_preview_position()
    get_viewport().add_child(_preview_canvas_layer)
    _preview_canvas_layer.add_child(drag_preview)
    _preview_canvas_layer.layer = EMBEDDED_WINDOWS_LAYER + 1

func drag_end():
    if !is_instance_valid(drag_preview):
        return

    _preview_canvas_layer.remove_child(drag_preview)
    _preview_canvas_layer.get_parent().remove_child(_preview_canvas_layer)
    drag_preview.mouse_filter = Control.MOUSE_FILTER_PASS

func activate():
    enabled = true

func deactivate():
    enabled = false

func is_dragged() -> bool:
    return _grabbed_draggable == self
#endregion

#region Private functions
static func _drop(zone: ControlDropZone):
    var grabbed_draggable = _grabbed_draggable
    grabbed_draggable.mouse_filter = Control.MOUSE_FILTER_PASS
    var local_drop_position = Vector2.ZERO

    if zone:
        local_drop_position = zone.get_drop_position()

    _grabbed_draggable = null
    _grab_offset = Vector2.ZERO
    grabbed_draggable.drag_end()
    grabbed_draggable.dropped.emit(zone, local_drop_position)
    draggable_dropped.emit(grabbed_draggable, zone, local_drop_position)

func _get_global_preview_position() -> Vector2:
    return get_global_mouse_position() - _grab_offset

func _notification(what):
    if what == NOTIFICATION_PREDELETE && is_instance_valid(_preview_canvas_layer):
        _preview_canvas_layer.queue_free()

func _process(_delta):
    if is_instance_valid(drag_preview):
        drag_preview.scale = get_global_transform().get_scale()
        drag_preview.global_position = _get_global_preview_position()

func _gui_input(event: InputEvent):
    if !enabled:
        return
        
    if !event is InputEventMouseButton:
        return

    var mouse_button_event: InputEventMouseButton = event
    if mouse_button_event.button_index != MOUSE_BUTTON_LEFT:
        return

    if mouse_button_event.is_pressed():
        grab(self)
#endregion