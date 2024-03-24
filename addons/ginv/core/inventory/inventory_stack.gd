@tool
class_name InventoryStack extends Inventory

#region Signals
signal capacity_changed
signal occupied_space_changed
#endregion

#region Exported vars
@export var capacity: float:
    get:
        if !constraint_manager:
            return 0.0
        if !constraint_manager.get_constraint_weight():
            return 0.0
        return constraint_manager.get_constraint_weight().capacity
    set(new_capacity):
         constraint_manager.get_constraint_weight().capacity = new_capacity
#endregion

#region Public vars
var occupied_space: float:
    get:
        if !constraint_manager:
            return 0.0
        if !constraint_manager.get_constraint_weight():
            return 0.0
        return constraint_manager.get_constraint_weight().occupied_space
    set(new_occupied_space):
        assert(false, "Occupied space, read only")
#endregion

#region Virtual functions
func _init():
    super._init()
    constraint_manager.enable_constraint_weight()
    constraint_manager.enable_constraint_stack()
    constraint_manager.get_constraint_weight().capacity_changed.connect(func(): capacity_changed.emit())
    constraint_manager.get_constraint_weight().occupied_space_changed.connect(func(): occupied_space_changed.emit())
#endregion

#region Public functions
func has_unlimited_capacity() -> bool:
    return constraint_manager.get_constraint_weight().has_unlimited_capacity()

func get_free_space() -> float:
    return constraint_manager.get_constraint_weight().get_free_space()

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
    return ConstraintStack.get_prototype_stack_size(protoset, prototype_id)

func get_prototype_max_stack_size(prototype_id: String) -> int:
    return ConstraintStack.get_prototype_max_stack_size(protoset, prototype_id)

func transfer_autosplit(item: Item, destination: InventoryStack) -> bool:
    return constraint_manager.get_constraint_stack().transfer_autosplit(item, destination)

func transfer_automerge(item: Item, destination: InventoryStack) -> bool:
    return constraint_manager.get_constraint_stack().transfer_automerge(item, destination)

func transfer_autosplitmerge(item: Item, destination: InventoryStack) -> bool:
    return constraint_manager.get_constraint_stack().transfer_autosplitmerge(item, destination)
#endregion