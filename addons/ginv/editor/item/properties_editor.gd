@tool
class_name PropertiesEditor extends Window

#region Constants
const COLOR_OVERRIDDEN = Color.GREEN
const COLOR_INVALID = Color.RED
#endregion

#region Public vars
var immutable_keys: Array[String] = [Protoset.KEY_ID, ConstraintGrid.KEY_GRID_POSITION]
var item: Item = null:
	set(new_item):
		if !new_item:
			return
		assert(!item)
		item = new_item
		if item.protoset:
			item.protoset.changed.connect(_refresh)
		_refresh()
#endregion

#region Onready vars
@onready var _margin_container: MarginContainer = $MarginContainer
@onready var _dict_editor: Control = $MarginContainer/DictEditor
#endregion

#region Virtual functions
func _ready():
	about_to_popup.connect(func(): _refresh())
	close_requested.connect(func(): hide())
	_dict_editor.value_changed.connect(func(key: String, new_value): _on_value_changed(key, new_value))
	_dict_editor.value_removed.connect(func(key: String): _on_value_removed(key))
	hide()
#endregion

#region Private functions
func _on_value_changed(key: String, new_value):
	var new_properties = item.properties.duplicate()
	new_properties[key] = new_value

	var item_prototype: Dictionary = item.protoset.get_prototype(item.prototype_id)

	if item_prototype.has(key) && item_prototype[key] == new_value:
		new_properties.erase(key)
	if new_properties.hash() == item.properties.hash():
		return
	
	GInvUndoRedo.set_item_properties(item, new_properties)
	_refresh()

func _on_value_removed(key: String):
	var new_properties = item.properties.duplicate()
	new_properties.erase(key)

	if new_properties.hash() == item.properties.hash():
		return
	
	GInvUndoRedo.set_item_properties(item, new_properties)
	_refresh()

func _refresh():
	_dict_editor.dictionary = _get_dictionary()
	_dict_editor.color_map = _get_color_map()
	_dict_editor.remove_button_map = _get_remove_button_map()
	_dict_editor.immutable_keys = immutable_keys
	_dict_editor.refresh()

func _get_dictionary() -> Dictionary:
	if !item || !item.protoset || !item.protoset.has_prototype(item.prototype_id):
		return {}
	
	var result: Dictionary = item.protoset.get_prototype(item.prototype_id).duplicate()
	
	for key in item.properties.keys():
		result[key] = item.properties[key]
	
	return result

func _get_color_map() -> Dictionary:
	if !item || !item.protoset:
		return {}
	
	var result: Dictionary = {}
	var dictionary: Dictionary = _get_dictionary()

	for key in dictionary.keys():
		if item.properties.has(key):
			result[key] = COLOR_OVERRIDDEN
		if key == Protoset.KEY_ID && !item.protoset.has_prototype(dictionary[key]):
			result[key] = COLOR_INVALID
	
	return result

func _get_remove_button_map() -> Dictionary:
	if !item || !item.protoset:
		return {}
	
	var result: Dictionary = {}
	var dictionary: Dictionary = _get_dictionary()

	for key in dictionary.keys():
		result[key] = {}
		if item.protoset.get_prototype(item.prototype_id).has(key):
			result[key]["text"] = ""
		else:
			result[key]["text"] = ""
		
		result[key]["disable"] = !key in item.properties || key in immutable_keys
	return result
#endregion
