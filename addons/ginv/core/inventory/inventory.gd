@tool
class_name Inventory extends Node

#region Signals
signal item_added(item: Item)
signal item_removed(item: Item)
signal item_modified(item: Item)
signal contents_changed
signal protoset_changed
#endregion

#region Constants
const KEY_NODE_NAME: String = "node_name"
const KEY_PROTOSET: String = "protoset"
const KEY_CONSTRAINTS: String = "constraints"
const KEY_CONTENTS: String = "contents"
#endregion

#region Exported vars
@export var protoset: Protoset:
	set(new_protoset):
		if new_protoset == protoset:
			return
		if !_contents.is_empty():
			return
		protoset = new_protoset
		protoset_changed.emit()
		update_configuration_warnings()
#endregion

#region Public vars
var constraint_manager: ConstraintManager = null
#endregion

#region Private vars
var _contents: Array[Item] = []
#endregion

#region Virtual functions
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not protoset:
		warnings.append("Inventory node must have protoset.")
	return warnings

func _init():
	constraint_manager = ConstraintManager.new(self)

func _ready():
	for item in _contents:
		_connect_item_signals(item)

func _enter_tree():
	for child in get_children():
		if !child is Item:
			continue
		if child in _contents:
			continue
		_contents.append(child)

func _exit_tree():
	_contents.clear()
#endregion

#region Public functions
func has_item(item: Item) -> bool:
	return item in _contents

func has_item_by_id(prototype_id: String) -> bool:
	if get_item_by_id(prototype_id):
		return true
	else:
		return false

func get_item_index(item: Item) -> int:
	return _contents.find(item)

func get_item_count() -> int:
	return _contents.size()

func get_item_by_id(prototype_id: String) -> Item:
	for item in get_all_items():
		if item.prototype_id == prototype_id:
			return item
	return null

func get_items_by_id(prototype_id: String) -> Array[Item]:
	var items: Array[Item] = []
	for item in get_all_items():
		if item.prototype_id == prototype_id:
			items.append(item)
	return items

func get_all_items() -> Array[Item]:
	return _contents

func move_item(from: int, to: int):
	assert(from >= 0 && from < _contents.size())
	assert(to >= 0 && to < _contents.size())
	if from == to:
		return
	_contents.insert(to, _contents.pop_at(from))

func transfer_item(item: Item, destination: Inventory) -> bool:
	if _can_remove_item(item) && destination.can_add_item(item):
		remove_item(item)
		destination.add_item(item)
		return true
	else:
		return false

func can_hold_item(_item: Item) -> bool:
	return true

func can_add_item(item: Item) -> bool:
	if item && !has_item(item) && can_hold_item(item) && constraint_manager.has_space_for(item):
		return true
	else:
		return false

func add_item(item: Item) -> bool:
	if can_add_item(item):
		if item.get_parent():
			item.get_parent().remove_child(item)
		add_child(item)
		if Engine.is_editor_hint():
			item.owner = get_tree().edited_scene_root
		return true
	return false

func create_and_add_item(prototype_id: String) -> Item:
	var item: Item = Item.new()
	item.protoset = protoset
	item.prototype_id = prototype_id
	if add_item(item):
		return item
	else:
		item.free()
		return null

func remove_item(item: Item) -> bool:
	if _can_remove_item(item):
		remove_child(item)
		return true
	else:
		return false

func remove_all_items():
	for child in get_children():
		if child is Item:
			remove_child(child)
	_contents = []

func reset():
	clear()
	protoset = null
	constraint_manager.reset()

func clear():
	for item in get_all_items():
		item.queue_free()
	remove_all_items()

func serialise() -> Dictionary:
	var result: Dictionary = {}
	result[KEY_NODE_NAME] = name as String
	result[KEY_PROTOSET] = protoset.resource_path
	result[KEY_CONSTRAINTS] = constraint_manager.serialise()
	if !get_all_items().is_empty():
		result[KEY_CONTENTS] = []
		for item in get_all_items():
			result[KEY_CONTENTS].append(item.serialise())
	return result

func deserialise(source: Dictionary) -> bool:
	if !Verify.dict(source, true, KEY_NODE_NAME, TYPE_STRING) \
	|| !Verify.dict(source, true, KEY_PROTOSET, TYPE_STRING) \
	|| !Verify.dict(source, false, KEY_CONTENTS, TYPE_ARRAY, TYPE_DICTIONARY) \
	|| !Verify.dict(source, false, KEY_CONSTRAINTS, TYPE_DICTIONARY):
		return false
	else:
		clear()
		protoset = null

		if !source[KEY_NODE_NAME].is_empty() && source[KEY_NODE_NAME] != name:
			name = source[KEY_NODE_NAME]

		protoset = load(source[KEY_PROTOSET])

		if source.has(KEY_CONSTRAINTS):
			constraint_manager.deserialise(source[KEY_CONSTRAINTS])

		if source.has(KEY_CONTENTS):
			var items = source[KEY_CONTENTS]
			for item_dict in items:
				var item: Item = Item.new()
				item.deseralise(item_dict)
				assert(add_item(item), "Failed to add item: {%s}" % item.prototype_id)
				
		return true
#endregion

#region Private functions
func _connect_item_signals(item: Item):
	if !item.protoset_changed.is_connected(_emit_item_modified):
		item.protoset_changed.connect(_emit_item_modified.bind(item))
	if !item.prototype_id_changed.is_connected(_emit_item_modified):
		item.prototype_id_changed.connect(_emit_item_modified.bind(item))
	if !item.properties_changed.is_connected(_emit_item_modified):
		item.properties_changed.connect(_emit_item_modified.bind(item))

func _disconnect_item_signals(item: Item):
	if item.protoset_changed.is_connected(_emit_item_modified):
		item.protoset_changed.disconnect(_emit_item_modified)
	if item.prototype_id_changed.is_connected(_emit_item_modified):
		item.prototype_id_changed.disconnect(_emit_item_modified)
	if item.properties_changed.is_connected(_emit_item_modified):
		item.properties_changed.disconnect(_emit_item_modified)

func _emit_item_modified(item: Item):
	constraint_manager._on_item_modified(item)
	item_modified.emit(item)

func _on_item_added(item: Item):
	_contents.append(item)
	contents_changed.emit()
	_connect_item_signals(item)
	if constraint_manager:
		constraint_manager._on_item_added(item)
	item_added.emit(item)

func _on_item_removed(item: Item):
	_contents.erase(item)
	contents_changed.emit()
	_disconnect_item_signals(item)
	if constraint_manager:
		constraint_manager._on_item_removed(item)
	item_removed.emit(item)

func _can_remove_item(item: Item) -> bool:
	return item && has_item(item)
#endregion
