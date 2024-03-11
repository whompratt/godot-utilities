@tool
class_name Item extends Node

#region Signals
signal protoset_changed
signal prototype_id_changed
signal properties_changed
signal added_to_inventory(inventory)
signal removed_from_inventory(inventory)
signal added_to_slot(slot)
signal removed_from_slot(slot)
#endregion

#region Constants
const KEY_PROTOSET: String = "protoset"
const KEY_PROTOTYPE_ID: String = "prototype_id"
const KEY_PROPERTIES: String = "properties"
const KEY_NODE_NAME: String = "node_name"
const KEY_TYPE: String = "type"
const KEY_VALUE: String = "value"
const KEY_IMAGE: String = "image"
const KEY_NAME: String = "name"
#endregion

#region Exported vars
@export var protoset: Protoset:
	set(new_protoset):
		if new_protoset == protoset:
			return
		if _inventory && protoset:
			return
		
		_disconnect_protoset_signals()
		protoset = new_protoset
		_connect_protoset_signals()

		if protoset && protoset._prototypes && protoset._prototypes.keys().size() > 0:
			prototype_id = protoset._prototypes.keys()[0]
		else:
			prototype_id = ""
		
		protoset_changed.emit()
		update_configuration_warnings()

@export var prototype_id: String:
	set(new_prototype_id):
		if new_prototype_id == prototype_id:
			return
		elif !protoset && new_prototype_id.is_empty():
			return
		elif protoset && !protoset.has_prototype(new_prototype_id):
			return
		prototype_id = new_prototype_id
		_reset_properties()
		update_configuration_warnings()
		prototype_id_changed.emit()

@export var properties: Dictionary:
	set(new_properties):
		properties = new_properties
		properties_changed.emit()
		update_configuration_warnings()
#endregion

#region Public vars

#endregion

#region Private vars
var _inventory: Inventory
var _slot: Slot
#endregion

#region Virtual functions
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if !protoset:
		warnings.append("A protoset is required to function")
	elif !protoset.has_prototype(prototype_id):
		warnings.append("No id found in protoset matching this item's id, '%s'" % prototype_id)
	
	return warnings

func _notification(what):
	if what == NOTIFICATION_PARENTED:
		_on_parented(get_parent())
	elif what == NOTIFICATION_UNPARENTED:
		_on_unparented()
#endregion

#region Public functions
func get_inventory() -> Inventory:
	return _inventory

func get_property(property_name: String, default_value = null) -> Variant:
	if properties.has(property_name):
		var value = properties[property_name]
		if value is Dictionary || value is Array:
			return value.duplicate()
		return value
	elif protoset && protoset.has_prototype(prototype_id):
		var prototype = protoset.get_prototype(prototype_id)
		if prototype && protoset.has_property(prototype, property_name):
			var value = protoset.get_property(prototype, property_name)
			if value is Dictionary || value is Array:
				return value.duplicate()
			return value
	return default_value

func set_property(property_name: String, new_value):
	if !properties.has(property_name) || new_value != properties[property_name]:
		properties[property_name] = new_value
		properties_changed.emit()

func clear_property(property_name: String):
	if properties.has(property_name):
		properties.erase(property_name)
		properties_changed.emit()

func reset():
	protoset = null
	prototype_id = ""
	properties = {}

func serialise() -> Dictionary:
	var result: Dictionary = {}

	result[KEY_NODE_NAME] = name as String
	result[KEY_PROTOSET] = protoset.resource_path
	result[KEY_PROTOTYPE_ID] = prototype_id

	if !properties.is_empty():
		result[KEY_PROPERTIES] = {}
		for property_name in properties.keys():
			result[KEY_PROPERTIES][property_name] = _serialise_property(property_name)
	
	return result

func deseralise(source: Dictionary) -> bool:
	if !Verify.dict(source, true, KEY_NODE_NAME, TYPE_STRING)\
	|| !Verify.dict(source, true, KEY_PROTOSET, TYPE_STRING)\
	|| !Verify.dict(source, true, KEY_PROTOTYPE_ID, TYPE_STRING)\
	|| !Verify.dict(source, false, KEY_PROPERTIES, TYPE_DICTIONARY):
		return false

	reset()

	if !source[KEY_NODE_NAME].is_empty() && source[KEY_NODE_NAME] != name:
		name = source[KEY_NODE_NAME]
	protoset = load(source[KEY_PROTOSET])
	prototype_id = source[KEY_PROTOTYPE_ID]

	if source.has(KEY_PROPERTIES):
		for key in source[KEY_PROPERTIES].keys():
			properties[key] = _deserialise_property(source[KEY_PROPERTIES][key])
			if properties[key] == null:
				properties = {}
				return false
	return true

func get_title() -> String:
	var title = get_property(KEY_NAME, prototype_id)
	if !title is String:
		title = prototype_id
	return title if title is String else prototype_id

func get_texture() -> Texture2D:
	var texture_path = get_property(KEY_IMAGE)
	if texture_path && texture_path != "" && ResourceLoader.exists(texture_path):
		var texture = load(texture_path)
		if texture is Texture2D:
			return texture
	return null
#endregion

#region Private functions
func _on_parented(parent: Node):
	if parent is Inventory:
		_on_added_to_inventory(parent as Inventory)
	else:
		_inventory = null
	
	if parent is Slot:
		_link_slot(parent as Slot)
	else:
		_unlink_slot()

func _on_unparented():
	# Todo: Is this really the best way to handle this?
	if _inventory:
		_on_removed_from_inventory(_inventory)
	_inventory = null
	_unlink_slot()

func _on_added_to_inventory(inventory: Inventory):
	assert(inventory, "Inventory not set")
	_inventory = inventory
	if _inventory.protoset:
		print_debug("Updating item's protoset from parent inventory")
		protoset = _inventory.protoset
	
	added_to_inventory.emit(_inventory)
	_inventory._on_item_added(self)

func _on_removed_from_inventory(inventory: Inventory):
	if inventory:
		removed_from_inventory.emit(inventory)
		inventory._on_item_removed(self)

func _link_slot(slot: Slot):
	_slot = slot
	_slot._on_item_added(self)
	added_to_slot.emit(slot)

func _unlink_slot():
	if _slot:
		var temp_slot: Slot = _slot
		_slot = null
		temp_slot.on_item_removed()
		removed_from_slot.emit(temp_slot)

func _connect_protoset_signals():
	if protoset:
		protoset.changed.connect(_on_protoset_changed)

func _disconnect_protoset_signals():
	if protoset:
		protoset.changed.disconnect(_on_protoset_changed)

func _on_protoset_changed():
	update_configuration_warnings()

func _reset_properties():
	if protoset && !prototype_id.is_empty():
		var prototype: Dictionary = protoset.get_prototype(prototype_id)
		var keys: Array = properties.keys().duplicate()
		for property in keys:
			if prototype.has(property):
				properties.erase(property)
	else:
		properties = {}

func _serialise_property(property_name: String) -> Dictionary:
	var result: Dictionary = {}
	var property_value = properties[property_name]
	var property_type = typeof(property_value)

	result = {
		KEY_TYPE: property_type,
		KEY_VALUE: var_to_str(property_value)
	}

	return result

func _deserialise_property(property: Dictionary):
	var result = str_to_var(property[KEY_VALUE])
	var expected_type: int = property[KEY_TYPE]
	var property_type: int = typeof(result)
	if property_type != expected_type:
		push_warning("Property has unexpected type. Expected {%s}, got {%s}" % [
			type_string(property_type), type_string(expected_type)
		])
		return null
	return result
#endregion
