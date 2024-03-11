class_name ConstraintStack extends Constraint

#region Enums
enum MergeResult {
    SUCCESS = 0,
    FAIL,
    PARTIAL,
}
#endregion

#region Constants
const KEY_STACK_SIZE: String = "stack_size"
const KEY_MAX_STACK_SIZE: String = "max_stack_size"
const DEFAULT_STACK_SIZE: int = 1
const DEFAULT_MAX_STACK_SIZE: int = 100
#endregion

#region Public functions
func get_space_for(_item: Item) -> int:
    return Count.INF

func has_space_for(_item: Item) -> bool:
    return true

func get_free_stack_space_for(item: Item) -> int:
    var item_count: int = 0
    var mergeable_items = get_mergeable_items(item)
    for mergeable_item in mergeable_items:
        item_count += ConstraintStack.get_free_space_in(mergeable_item)
    return item_count

func get_all_stack_space_for(item: Item) -> int:
    var item_count: int = 0
    var mergeable_items = get_mergeable_items(item)
    for mergeable_item in mergeable_items:
        item_count += ConstraintStack.get_free_space_in(mergeable_item)
    return item_count

func get_mergeable_items(item: Item) -> Array[Item]:
    var result: Array[Item] = []
    for inventory_item in inventory.get_items():
        if inventory_item == item:
            continue
        if !ConstraintStack.is_items_mergeable(inventory_item, item):
            continue
        result.append(inventory_item)
    return result

func add_item_and_automerge(item: Item) -> bool:
    if !inventory.constraint_manager.has_space_for(item):
        return false
    var target_items = get_mergeable_items(item)
    for target_item in target_items:
        if ConstraintStack.merge_stacks(item, target_item) == MergeResult.SUCCESS:
            return true
    return inventory.add_item(item)

func pack_item(item: Item):
    var free_space: int = get_all_stack_space_for(item)

    if free_space == 0:
        return
    
    var stack_size: int = ConstraintStack.get_item_stack_size(item)
    if stack_size > free_space:
        item = ConstraintStack.split_stack(item, free_space)
    
    var mergeable_items = get_mergeable_items(item)
    for mergeable_item in mergeable_items:
        var merge_result: int = ConstraintStack.merge_stacks(item, mergeable_item)
        if merge_result == MergeResult.SUCCESS:
            return

func transfer_to_autosplit(item: Item, destination: Inventory) -> Item:
    if inventory.constraint_manager.get_configuration() != destination.constraint_manager.get_configuration():
        push_warning("Inventory configurations do not match for autosplit")
        return item
    
    var stack_size: int = ConstraintStack.get_item_stack_size(item)
    if stack_size <= 1:
        return null
    
    var free_space: int = _get_space_for_single_item(item, destination)
    if free_space == Count.INF:
        push_warning("Item count should not be infinite")
        return null
    elif free_space <= 0:
        return null
    
    var new_item: Item = ConstraintStack.split_stack(item, free_space)
    destination.add_item(new_item)
    return new_item

func transfer_to_automerge(item: Item, destination: Inventory) -> bool:
    if inventory.transfer(item, destination):
        if item.is_queued_for_deletion():
            return true
        destination.constraint_manager.get_constraint_stack().pack_item(item)
        return true
    return false

func transfer_to_autosplit_and_automerge(item: Item, destination: Inventory) -> bool:
    var new_item: Item  = transfer_to_autosplit(item, destination)
    if new_item:
        if new_item.is_queued_for_deletion():
            return true
        destination.constraint_manager.get_constraint_stack().pack_item(new_item)
        return true
    return false
#endregion

#region Private functions
func _get_space_for_single_item(item: Item, destination: Inventory) -> int:
    var single_item: Item = item.duplicate()
    ConstraintStack.set_item_stack_size(single_item, 1)
    var count: int = destination.constraint_manager.get_space_for(single_item)
    single_item.free()
    return count
#endregion

#region Static functions
static func get_free_space_in(item: Item) -> int:
    assert(item, "Item is null")
    return get_item_max_stack_size(item) - get_item_stack_size(item)

static func has_custom_property(item: Item, property: String, value) -> bool:
    assert(item, "Item is null")
    return item.properties.has(property) && item.properties[property] == value

static func get_item_stack_size(item: Item) -> int:
    assert(item, "Item is null")
    return item.get_property(KEY_STACK_SIZE, DEFAULT_STACK_SIZE)

static func get_item_max_stack_size(item: Item) -> int:
    assert(item, "Item is null")
    return item.get_property(KEY_MAX_STACK_SIZE, DEFAULT_MAX_STACK_SIZE)

static func set_item_stack_size(item: Item, new_stack_size: int) -> bool:
    assert(item, "Item is null")
    assert(new_stack_size >= 0, "New stack size cannot be negative")
    if new_stack_size > get_item_max_stack_size(item):
        push_warning("Attempted to set stack size above max stack size")
        return false
    if new_stack_size == 0:
        var item_inventory: Inventory = item.get_inventory()
        if item_inventory:
            item_inventory.remove_item(item)
        item.queue_free()
        return true
    item.set_property(KEY_STACK_SIZE, new_stack_size)
    return true

static func set_item_max_stack_size(item: Item, new_max_stack_size: int):
    item.set_property(KEY_MAX_STACK_SIZE, new_max_stack_size)

static func get_prototype_stack_size(protoset: Protoset, prototype: Dictionary) -> int:
    return protoset.get_property(prototype, KEY_STACK_SIZE, 1.0)

static func get_prototype_max_stack_size(protoset: Protoset, prototype: Dictionary) -> int:
    return protoset.get_property(prototype, KEY_MAX_STACK_SIZE, 1.0)

static func is_items_mergeable(first_item: Item, second_item: Item) -> bool:
    var ignore_properties: Array[String] = [
        KEY_STACK_SIZE,
        KEY_MAX_STACK_SIZE,
        ConstraintGrid.KEY_GRID_POSITION,
        ConstraintWeight.KEY_WEIGHT,
    ]

    if first_item.prototype_id != second_item.prototype_id:
        return false
    
    for property in first_item.properties.keys():
        if property in ignore_properties:
            continue
        elif !has_custom_property(second_item, property, first_item.properties[property]):
            return false
    for property in second_item.properties.keys():
        if property in ignore_properties:
            continue
        elif !has_custom_property(first_item, property, second_item.properties[property]):
            return false
    return true

static func merge_stacks(first_item: Item, second_item: Item) -> int:
    if !is_items_mergeable(second_item, first_item):
        return MergeResult.FAIL

    var source_item_stack_size: int = get_item_stack_size(first_item)
    var second_item_stack_size: int = get_item_stack_size(second_item)
    var second_item_max_stack_size: int = get_item_max_stack_size(second_item)
    var second_item_free_space: int = second_item_max_stack_size - second_item_stack_size
    
    if second_item_free_space <= 0:
        return MergeResult.FAIL
    elif second_item_free_space >= source_item_stack_size:
        return MergeResult.SUCCESS
    else:
        return MergeResult.PARTIAL

static func split_stack(item: Item, new_stack_size: int) -> Item:
    var stack_size = get_item_stack_size(item)
    var new_item = item.duplicate()

    if new_item.get_parent():
        new_item.get_parent().remove_child(new_item)
    assert(set_item_stack_size(new_item, new_stack_size))
    assert(set_item_stack_size(item, stack_size - new_stack_size))
    return new_item
#endregion