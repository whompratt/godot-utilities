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
const KEY_ITEM_PROTOSET: String = "protoset"
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
		_connect_item_signal(item)

func _enter_tree():
	for child in get_children():
		if not child is Item:
			continue
		if child in _contents:
			continue
		_contents.append(child)

func _exit_tree():
	_contents.clear()
#endregion

#region Public functions
func move_item(from: int, to: int):
	assert(from >= 0 && from < _contents.size())
	assert(to >= 0 && to < _contents.size())
	if from == to:
		return
	_contents.insert(to, _contents.pop_at(from))

func get_item_index(item: Item) -> int:
	return _contents.find(item)

func get_item_count() -> int:
	return _contents.size()

func get_all_items() -> Array[Item]:
	return _contents

func has_item(item: Item) -> bool:
	return item in _contents

func can_add_item(item: Item) -> bool:
	if item && !has_item(item) && can_hold_item(item)

func add_item(item: Item) -> bool:
	if can_add_item(item):
		if item.get_parent():
			item.get_parent().remove_child(item)
		add_child(item)
		if Engine.is_editor_hint():
			item.owner = get_tree().edited_scene_root
		return true
	return false
#endregion

#region Private functions
func _connect_item_signal(item: Item):
	if !item.protoset_changed.is_connected(_emit_item_modified):
		item.protoset_changed.connect(_emit_item_modified.bind(item))
	if !item.prototype_id_changed.is_connected(_emit_item_modified):
		item.prototype_id_changed.connect(_emit_item_modified.bind(item))
	if !item.properties_changed.is_connected(_emit_item_modified):
		item.properties_changed.connect(_emit_item_modified.bind(item))

func _disconnect_item_signal(item: Item):
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
	_connect_item_signal(item)
	if constraint_manager:
		constraint_manager._on_item_added(item)
	item_added.emit(item)

func _on_item_removed(item: Item):
	_contents.erase(item)
	contents_changed.emit()
	_disconnect_item_signal(item)
	if constraint_manager:
		constraint_manager._on_item_removed(item)
	item_removed.emit(item)
#endregion