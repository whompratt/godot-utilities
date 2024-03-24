@tool
class_name InventoryGridStack extends InventoryGrid

#region Virtual functions
func _init():
	super._init()
	constraint_manager.enable_constraint_stack()
#endregion

#region Public functions
func has_place_for(item: Item) -> bool:
	return constraint_manager.has_space_for(item)

func add_item_automerge(item: Item) -> bool:
	return constraint_manager.get_constraint_stack().add_item_automerge(item)

func split(item: Item, new_stack_size: int) -> Item:
	return constraint_manager.get_constraint_stack().split_stack_safe(item, new_stack_size)

func join(item_source: Item, item_destination: Item) -> bool:
	return constraint_manager.get_constraint_stack().merge_stacks(item_source, item_destination)

static func get_item_stack_size(item: Item) -> int:
	return ConstraintStack.get_item_stack_size(item)

static func set_item_stack_size(item: Item, new_stack_size: int) -> bool:
	return ConstraintStack.set_item_stack_size(item, new_stack_size)

static func get_item_max_stack_size(item: Item) -> int:
	return ConstraintStack.get_item_max_stack_size(item)

static func set_item_max_stack_size(item: Item, new_stack_size: int):
	ConstraintStack.set_item_max_stack_size(item, new_stack_size)

func get_prototype_stack_size(prototype_id: String) -> int:
	return constraint_manager.get_constraint_stack().get_prototype_stack_size(protoset, prototype_id)

func get_prototype_max_stack_size(prototype_id: String) -> int:
	return constraint_manager.get_constraint_stack().get_prototype_max_stack_size(protoset, prototype_id)

func transfer_automerge(item: Item, destination: Inventory) -> bool:
	return constraint_manager.get_constraint_stack().transfer_automerge(item, destination)

func transfer_autosplitmerge(item: Item, destination: Inventory) -> bool:
	return constraint_manager.get_constraint_stack().transfer_autosplitmerge(item, destination)

func transfer_to(item: Item, destination: Inventory, position: Vector2i) -> bool:
	return constraint_manager.get_constraint_grid().transfer_to(item, destination.constraint_manager.get_constraint_grid(), position)

func _get_mergeable_item_at(item: Item, position: Vector2i) -> Item:
	return constraint_manager.get_constraint_grid()._get_mergeable_item_at(item, position)
#endregion
