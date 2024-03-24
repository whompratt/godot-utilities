extends EditorProperty

#region Constants
const PROTOTYPE_EDITOR = preload("res://addons/ginv/editor/item/prototype_id_editor.tscn")
const POPUP_SIZE = Vector2i(300, 300)
const COLOR_INVALID = Color.RED
#endregion

#region Public vars
var current_value: String
var updating: bool = false
#endregion

#region Private vars
var _prototype_id_editor: Window
var _button_prototype_id: Button
#endregion

#region Virtual functions
func _init():
    _prototype_id_editor = PROTOTYPE_EDITOR.instantiate()
    add_child(_prototype_id_editor)

    _button_prototype_id = Button.new()
    _button_prototype_id.text = "Prototype ID"
    _button_prototype_id.pressed.connect(_on_button_prototype_id)
    add_child(_button_prototype_id)

func _ready() -> void:
    var item: Item = get_edited_object()
    _prototype_id_editor.item = item
    item.prototype_id_changed.connect(_refresh_button)
    if item.protoset:
        item.protoset.changed.connect(_refresh_button)
    _refresh_button()
#endregion

#region Private functions
func _on_button_prototype_id() -> void:
    _prototype_id_editor.popup_centered(POPUP_SIZE)

func _get_popup_at_mouse_position(size: Vector2i) -> Vector2i:
    var global_mouse_pos: Vector2i = Vector2i(get_global_mouse_position())
    var local_mouse_pos: Vector2i = global_mouse_pos + \
    DisplayServer.window_get_position(DisplayServer.MAIN_WINDOW_ID)
    
    var screen_size: Vector2i = DisplayServer.screen_get_size(DisplayServer.SCREEN_OF_MAIN_WINDOW)
    var popup_pos: Vector2i
    popup_pos.x = clamp(local_mouse_pos.x, 0, screen_size.x - size.x)
    popup_pos.y = clamp(local_mouse_pos.y, 0, screen_size.y - size.y)

    return popup_pos

func update_property() -> void:
    var new_value = get_edited_object()[get_edited_property()]
    if current_value == new_value:
        return

    updating = true
    current_value = new_value
    _refresh_button()
    updating = false

func _refresh_button() -> void:
    var item: Item = get_edited_object()
    _button_prototype_id.text = item.prototype_id
    if !item.protoset.has_prototype(item.prototype_id):
        _button_prototype_id.add_theme_color_override("font_color", COLOR_INVALID)
        _button_prototype_id.add_theme_color_override("font_color_hover", COLOR_INVALID)
        _button_prototype_id.tooltip_text = "Invalid prototype ID!"
    else:
        _button_prototype_id.remove_theme_color_override("font_color")
        _button_prototype_id.remove_theme_color_override("font_color_hover")
        _button_prototype_id.tooltip_text = ""
#endregion