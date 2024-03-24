@tool
extends Control

#region Signals
signal value_changed(key, value)
signal value_removed(key)
#endregion

#region Constants
const SUPPORTED_TYPES: Array[int] = [
	TYPE_BOOL,
	TYPE_INT,
	TYPE_FLOAT,
	TYPE_STRING,
	TYPE_VECTOR2,
	TYPE_VECTOR2I,
	TYPE_RECT2,
	TYPE_RECT2I,
	TYPE_VECTOR3,
	TYPE_VECTOR3I,
	TYPE_PLANE,
	TYPE_QUATERNION,
	TYPE_AABB,
	TYPE_COLOR,
]
#endregion

#region Exported vars
@export var dictionary: Dictionary:
	set(new_dictionary):
		dictionary = new_dictionary
		refresh()
@export var color_map: Dictionary:
	set(new_color_map):
		color_map = new_color_map
		refresh()
@export var remove_button_map: Dictionary:
	set(new_remove_button_map):
		remove_button_map = new_remove_button_map
		refresh()
@export var immutable_keys: Array[String]:
	set(new_immutable_keys):
		immutable_keys = new_immutable_keys
		refresh()
@export var default_color: Color = Color.WHITE:
	set(new_default_color):
		default_color = new_default_color
		refresh()
#endregion

#region Onready vars
@onready var grid_container = $VBoxContainer/ScrollContainer/GridContainer
@onready var label_name = $VBoxContainer/ScrollContainer/GridContainer/LabelTitleName
@onready var label_type = $VBoxContainer/ScrollContainer/GridContainer/LabelTitleType
@onready var label_value = $VBoxContainer/ScrollContainer/GridContainer/LabelTitleValue
@onready var control_dummy = $VBoxContainer/ScrollContainer/GridContainer/ControlDummy
@onready var edit_property_name = $VBoxContainer/HBoxContainer/EditPropertyName
@onready var opt_type = $VBoxContainer/HBoxContainer/OptType
@onready var button_add = $VBoxContainer/HBoxContainer/ButtonAdd
#endregion

#region Virtual functions
func _ready():
	button_add.pressed.connect(_on_button_add)
	edit_property_name.text_submitted.connect(_on_text_entered)
	refresh()
#endregion

#region Public functions
func refresh():
	if !is_inside_tree():
		return
	_clear()
	label_name.add_theme_color_override("font_color", default_color)
	label_type.add_theme_color_override("font_color", default_color)
	label_value.add_theme_color_override("font_color", default_color)
	_refresh_add_property()
	_populate()

func set_remove_button_config(key: String, config: Dictionary):
	remove_button_map[key] = config
	refresh()
#endregion

#region Private functions
func _on_button_add():
	var property_name: String = edit_property_name.text
	var type: int = opt_type.get_selected_id()
	if _add_dict_field(property_name, type):
		value_changed.emit(property_name, dictionary[property_name])
	refresh()

func _on_text_entered(_new_text: String):
	_on_button_add()

func _add_dict_field(property_name: String, type: int) -> bool:
	if property_name.is_empty() || type < 0 || dictionary.has(property_name):
		return false
	dictionary[property_name] = Verify.create_var(type)
	return true

func _refresh_add_property():
	for type in SUPPORTED_TYPES:
		opt_type.add_item(Verify.TYPE_NAMES[type], type)
	opt_type.select(SUPPORTED_TYPES.find(TYPE_STRING))

func _clear():
	edit_property_name.text = ""
	opt_type.clear()

	for child in grid_container.get_children():
		if child == label_name || child == label_type || child == label_value || child == control_dummy:
			continue
		child.queue_free()

func _populate():
	for key in dictionary.keys():
		var color: Color = default_color
		if color_map.has(key) && typeof(color_map[key]) == TYPE_COLOR:
			color = color_map[key]
		_add_key(key, color)

func _add_key(key: String, color: Color):
	if !key is String:
		return

	_add_label(key, color)
	_add_label(Verify.TYPE_NAMES[typeof(dictionary[key])], color)
	_add_value_editor(key)
	_add_remove_button(key)

func _add_label(key: String, color: Color):
	var label: Label = Label.new()
	label.text = key
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", color)
	grid_container.add_child(label)

func _add_value_editor(key: String):
	var value_editor: Control = ValueEditor.new()
	value_editor.value = dictionary[key]
	value_editor.size_flags_horizontal = SIZE_EXPAND_FILL
	value_editor.enabled = not key in immutable_keys
	value_editor.value_changed.connect(_on_value_changed.bind(key, value_editor))
	grid_container.add_child(value_editor)

func _on_value_changed(key: String, value_editor: Control):
	dictionary[key] = value_editor.value
	value_changed.emit(key, value_editor.value)

func _add_remove_button(key: String):
	var button: Button = Button.new()
	button.text = "Remove"
	if remove_button_map.has(key):
		var remove_button = remove_button_map[key]
		button.text = remove_button.text
		button.disabled = remove_button.disabled
	button.pressed.connect(_on_remove_button.bind(key))
	grid_container.add_child(button)

func _on_remove_button(key: String):
	dictionary.erase(key)
	value_removed.emit(key)
	refresh()
#endregion
