extends EditorProperty

#region Constants
const POPUP_SIZE = Vector2i(800, 300)
const PROPERTIES_EDITOR = preload("res://addons/ginv/editor/item/properties_editor.tscn")
#endregion

#region Public vars
var current_value: Dictionary
var updating: bool = false
#endregion

#region Private vars
var _button_prototype_id: Button
var _properties_editor: Window
#endregion

#region Virtual functions
func _init():
    _properties_editor = PROPERTIES_EDITOR.instantiate()
    add_child(_properties_editor)

    _button_prototype_id = Button.new()
    _button_prototype_id.text = "Edit Properties"
    _button_prototype_id.pressed.connect(_on_button_edit)
    add_child(_button_prototype_id)

func _ready():
    var item: Item = get_edited_object()

    if !item:
        return
    
    _properties_editor.item = item
    item.properties_changed.connect(update_property)

    if !item.protoset:
        return
    
    item.protoset.changed.connect(_on_protoset_changed)
    _refresh_button()
#endregion

#region Public functions
func update_property():
    var new_value = get_edited_object()[get_edited_property()]
    
    if current_value == new_value:
        return
    
    updating = true
    current_value = new_value
    updating = false
#endregion

#region Private functions
func _on_button_edit():
    _properties_editor.popup_centered(POPUP_SIZE)

func _on_protoset_changed():
    _refresh_button()

func _refresh_button():
    var item: Item = get_edited_object()
    
    if !item || !item.protoset:
        return
    
    _button_prototype_id.disabled = !item.protoset.has_prototype(item.prototype_id)
#endregion