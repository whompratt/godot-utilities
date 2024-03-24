@tool
class_name Protoset extends Resource

#region Constants
const KEY_ID: String = "id"
#endregion


#region Export vars
@export var json_data: JSON:
	set(new_json_data):
		json_data = new_json_data
		if json_data && json_data.data:
			if !OS.has_feature("release"):
				_validate_json(json_data)
			_update_prototypes(json_data)
		_save()
#endregion


#region Public vars
var prototypes: Dictionary = {}:
	set(new_prototypes):
		prototypes = new_prototypes
		_update_json_data()
		_save()
#endregion


#region Private functions
## Use asserts to validate the new [param JSON] data. This function is only called in debug builds
func _validate_json(json: JSON):
	assert(json.data is Array, "Protoset JSON top level must be array")
	for prototype in json.data:
		assert(prototype is Dictionary, "Item prototypes must be a dictionary")
		assert(prototype.has(KEY_ID), "Prototype must have an '%s' property" % KEY_ID)
		assert(prototype[KEY_ID] is String, "Property '%s' must be a string" % KEY_ID)
		assert(!prototypes.has(prototype[KEY_ID]), "Prototype '%s' property must be unique, but '%s' already exists" % [KEY_ID, prototype[KEY_ID]])


## Writes the contents of the [member Protoset.json_data] member into the [memeber Protoset.prototypes] member.[br]
## NOTE: If a .json or .tres file is loaded, updating the contents of the file will [i]not[/i] cause this function to be called.
func _update_prototypes(json: JSON):
	prototypes.clear()
	var protoset: Array = json.data
	for prototype: Dictionary in protoset:
		prototypes[prototype[KEY_ID]] = prototype


## Writes the contents of the [member Protoset.prototypes] member into the [member Protoset.json_data] member.[br]
## This function [i]is[/i] called when [member Protoset.prototypes] is updated manually, unlike the
## JSON resource's behaviour.
func _update_json_data():
	var new_data: Array[Dictionary] = []
	for prototype_id: String in prototypes.keys():
		new_data.append(get_prototype(prototype_id))
	json_data.data = new_data


## Saves this [Protoset] resource to the file system.
func _save():
	emit_changed()
	if !resource_path.is_empty():
		ResourceSaver.save(self)
#endregion


#region Prototype functions
## Return true if prototype of the given [param id] exists
func has_prototype(id: String) -> bool:
	return prototypes.has(id)


## Return the prototype of the given [param id]
func get_prototype(id: StringName) -> Dictionary:
	assert(prototypes.has(id), "No prototype with Id %s" % id)
	return prototypes[id]


## Add a new empty prototype to the [property prototypes] Array with the given [param id]
func add_prototype(id: String):
	assert(!has_prototype(id), "Prototype with id '%s' already exists" % id)
	prototypes[id] = {KEY_ID: id}
	_update_json_data()
	_save()


## Erase the given prototype from the [property prototypes] Array.
func remove_prototype(prototype_id: String):
	prototypes.erase(prototype_id)
	_update_json_data()
	_save()


# Todo: Can common logic between this, add_, and rename_ be abstracted?
## Utility: Duplicate the given prototype, appending _duplicate to the [constant KEY_ID]
func duplicate_prototype(prototype: Dictionary):
	var new_id = "%s_duplicate" % prototype[KEY_ID]
	assert(!has_prototype(new_id), "Prototype with id '%s' already exists" % new_id)
	add_prototype(new_id)
	prototypes[new_id] = prototype.duplicate()
	prototypes[new_id][KEY_ID] = new_id
	_update_json_data()
	_save()


## Rename the given [param prototype], functionally removing the [param prototype] of the
## original id, and creating a new prototype with the given [param new_id]
func rename_prototype(prototype: Dictionary, new_id: String):
	assert(!has_prototype(new_id), "Prototype with id '%s' already exists" % new_id)
	add_prototype(new_id)
	prototypes[new_id] = prototype.duplicate()
	prototypes[new_id][KEY_ID] = new_id
	remove_prototype(prototype[KEY_ID])
	_update_json_data()
	_save()
#endregion


#region Property functions
## Return true if prototype of the given [param id] has a property [param property_name]
func has_property(prototype: Dictionary, property_name: String) -> bool:
	return prototype.has(property_name)


## Return the value of the [param property_name] for the prototype of the given [param id]
func get_property(prototype: Dictionary, property_name: String, default_value = null) -> Variant:
	assert(has_property(prototype, property_name), "Prototype '%s' has no property '%s'" % [prototype.id, property_name])
	return prototype[property_name] if has_property(prototype, property_name) else default_value


## Set the [param value] of the [param property_name] for the given [param prototype]
func set_property(prototype: Dictionary, property_name: String, value: Variant):
	prototype[property_name] = value
#endregion
