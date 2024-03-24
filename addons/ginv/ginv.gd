@tool
extends EditorPlugin

#region Vars
var inspector_plugin: EditorInspectorPlugin
static var _instance: EditorPlugin
#endregion

#region Virtual functions
func _init():
	_instance = self

func _enter_tree():
	inspector_plugin = preload("res://addons/ginv/editor/inventory_inspector_plugin.gd").new()
	add_inspector_plugin(inspector_plugin)
	_add_settings()

func _exit_tree():
	remove_inspector_plugin(inspector_plugin)
#endregion

#region Public functions
static func instance() -> EditorPlugin:
	return _instance
#endregion

#region Private functions
func _add_settings():
	_add_setting("ginv/inspector_control_height", TYPE_INT, 200)
	_add_setting("ginv/JSON_serialisation/indent_using_spaces", TYPE_BOOL, true)
	_add_setting("ginv/JSON_serialisation/indent_size", TYPE_INT, 4)
	_add_setting("ginv/JSON_serialisation/sort_keys", TYPE_BOOL, true)
	_add_setting("ginv/JSON_serialisation/full_prevision", TYPE_BOOL, false)

func _add_setting(name: String, type: int, value):
	if !ProjectSettings.has_setting(name):
		ProjectSettings.set(name, value)
	
	var property_info = {
		"name": name,
		"type": type
	}

	ProjectSettings.add_property_info(property_info)
	ProjectSettings.set_initial_value(name, value)
#endregion
