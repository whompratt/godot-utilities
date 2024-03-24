@tool
extends Control

#region Public vars
var protoset: Protoset:
	set(new_protoset):
		protoset = new_protoset
		if protoset:
			protoset.changed.connect(_on_protoset_changed)
		_refresh()

var selected_prototype_id: String = ""
#endregion

#region @onready vars
@onready var prototype_filter = $"%PrototypeFilter"
@onready var property_editor = $"%PropertyEditor"
@onready var text_prototype_id = $"%TextPrototypeId"
@onready var button_add_prototype = $"%ButtonAddPrototype"
@onready var button_duplicate_prototype = $"%ButtonDuplicatePrototype"
@onready var button_remove_prototype = $"%ButtonRemovePrototype"
@onready var button_rename_prototype = $"%ButtonRenamePrototype"
#endregion

#region Virtual functions
func _ready():
	prototype_filter.choice_selected.connect(_on_prototype_selected)
	property_editor.value_changed.connect(_on_property_changed)
	property_editor.value_removed.connect(_on_property_removed)
	text_prototype_id.text_changed.connect(_on_prototype_id_changed)
	text_prototype_id.text_submitted.connect(_on_prototype_id_entered)
	button_add_prototype.pressed.connect(_on_button_add_prototype)
	button_duplicate_prototype.pressed.connect(_on_button_duplicate_prototype)
	button_rename_prototype.pressed.connect(_on_button_rename_prototype)
	button_remove_prototype.pressed.connect(_on_button_remove_prototype)

	_refresh()
#endregion

#region Private functions
func _refresh():
	if visible:
		_clear()
		_populate()
		_refresh_button_add_prototype()
		_refresh_button_rename_prototype()
		_refresh_button_remove_prototype()
		_refresh_button_duplicate_prototype()
		_inspect_prototype_id(selected_prototype_id)

func _clear():
	prototype_filter.values.clear()
	property_editor.dictionary.clear()
	property_editor.refresh()

func _populate():
	if protoset:
		prototype_filter.set_values(protoset.prototypes.keys().duplicate())

func _refresh_button_add_prototype():
	button_add_prototype.disabled = text_prototype_id.text.is_empty() \
	|| protoset.has_prototype(text_prototype_id.text)

func _refresh_button_rename_prototype():
	button_rename_prototype.disabled = text_prototype_id.text.is_empty() \
	|| protoset.has_prototype(text_prototype_id.text)

func _refresh_button_remove_prototype():
	button_remove_prototype.disabled = prototype_filter.get_selected_text().is_empty()

func _refresh_button_duplicate_prototype():
	button_duplicate_prototype.disabled = prototype_filter.get_selected_text().is_empty()

func _on_protoset_changed():
	_refresh()

func _on_prototype_selected(index: int):
	selected_prototype_id = prototype_filter.values[index]
	_inspect_prototype_id(selected_prototype_id)
	_refresh_button_remove_prototype()
	_refresh_button_duplicate_prototype()

func _inspect_prototype_id(prototype_id: String):
	if !protoset || !protoset.has_prototype(prototype_id):
		return
	
	var prototype: Dictionary = protoset.get_prototype(prototype_id).duplicate()

	property_editor.dictionary = prototype
	property_editor.immutable_keys = [Protoset.KEY_ID] as Array[String]
	property_editor.remove_button_map = {}

	for property_name in prototype.keys():
		property_editor.set_remove_button_config(property_name, {
			"text": "",
			"disabled": property_name == Protoset.KEY_ID
		})

func _on_property_changed(property_name: String, new_value):
	if selected_prototype_id.is_empty():
		return

	var new_properties = protoset.get_prototype(selected_prototype_id).duplicate()
	new_properties[property_name] = new_value

	if new_properties.hash() == protoset.get_prototype(selected_prototype_id).hash():
		return
	
	GInvUndoRedo.set_prototype_properties(protoset, selected_prototype_id, new_properties)

func _on_property_removed(property_name: String):
	if selected_prototype_id.is_empty():
		return
	
	var new_properties = protoset.get_prototype(selected_prototype_id).duplicate()
	new_properties.erase(property_name)

	GInvUndoRedo.set_prototype_properties(protoset, selected_prototype_id, new_properties)

func _on_prototype_id_changed(_prototype_id: String):
	_refresh_button_add_prototype()
	_refresh_button_rename_prototype()

func _on_prototype_id_entered(prototype_id: String):
	_add_prototype_id(prototype_id)

func _on_button_add_prototype():
	_add_prototype_id(text_prototype_id.text)

func _on_button_duplicate_prototype():
	GInvUndoRedo.duplicate_prototype(protoset, selected_prototype_id)

func _on_button_rename_prototype():
	if selected_prototype_id.is_empty():
		return
	
	GInvUndoRedo.rename_prototype(
		protoset,
		selected_prototype_id,
		text_prototype_id.text
	)

	text_prototype_id.text = ""

func _add_prototype_id(prototype_id: String):
	GInvUndoRedo.add_prototype(protoset, prototype_id)
	text_prototype_id.text = ""

func _on_button_remove_prototype():
	if selected_prototype_id.is_empty():
		return
	
	var prototype_id = selected_prototype_id

	if !prototype_id.is_empty():
		GInvUndoRedo.remove_prototype(protoset, prototype_id)
#endregion
