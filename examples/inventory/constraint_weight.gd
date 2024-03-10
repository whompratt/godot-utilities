class_name ConstraintWeight extends Constraint

#region Signals
signal capacity_changed
signal weight_changed
#endregion

#region Constants
const KEY_WEIGHT: String = "weight"
const KEY_CAPACITY: String = "capacity"
const KEY_USED_WEIGHT: String = "used_weight"
#endregion

#region Public vars
var capacity: float:
    set(new_capacity):
        if new_capacity < 0.0:
            new_capacity = 0.0
        if new_capacity == capacity:
            return
        elif new_capacity > 0.0 && _used_weight > new_capacity:
            return
        else:
            capacity = new_capacity
            capacity_changed.emit()
#endregion

#region Private vars
var _used_weight: float
#endregion

#region Functions
#region Virtual functions
func _init(new_inventory: Inventory, new_capacity: float = 0.0):
    super(new_inventory)
    capacity = new_capacity
#endregion

#region Public functions
func reset():
    capacity = 0.0

func has_unlimited_capacity() -> bool:
    return capacity == 0.0

func get_free_space() -> float:
    if has_unlimited_capacity():
        return capacity
    else:
        var free_space: float = capacity - _used_weight
        if free_space < 0.0:
            free_space = 0.0
        return free_space

func has_space_for(item: Item) -> bool:
    if has_unlimited_capacity():
        return true
    return get_free_space() >= ConstraintWeight.get_item_weight(item)

func get_space_for(item: Item) -> int:
    if has_unlimited_capacity():
        return Count.INF
    return floor(get_free_space() /  ConstraintWeight._get_item_unit_weight(item))

func serialise() -> Dictionary:
    var result: Dictionary = {}

    result[KEY_CAPACITY] = capacity
    result[KEY_WEIGHT] = _used_weight

    return result

func deserialise(source: Dictionary) -> bool:
    if !Verify.dict(source, true, KEY_CAPACITY, TYPE_FLOAT) \
    || !Verify.dict(source, true, KEY_USED_WEIGHT, TYPE_FLOAT):
        return false
    
    reset()
    capacity = source[KEY_CAPACITY]
    _used_weight = source[KEY_USED_WEIGHT]
    return true
#endregion

#region Private functions
func _calculate_occupied_space():
    var current_weight = _used_weight
    _used_weight = 0.0

    for item in inventory.get_items():
        _used_weight += ConstraintWeight.get_item_weight(item)
    
    if _used_weight != current_weight:
        weight_changed.emit()

func _on_inventory_set():
    _calculate_occupied_space()

func _on_item_added(_item: Item):
    _calculate_occupied_space()

func _on_item_removed(_item: Item):
    _calculate_occupied_space()

func _on_item_modified(_item: Item):
    _calculate_occupied_space()
#endregion

#region Static functions
static func get_item_weight(item: Item) -> float:
    if !item:
        return -1.0
    return _get_item_unit_weight(item) * ConstraintStack.get_item_stack_size(item)

static func _get_item_unit_weight(item: Item) -> float:
    return item.get_property(KEY_WEIGHT, 1.0)

static func set_item_weight(item: Item, new_weight: float):
    if new_weight == 0.0:
        push_error("New item weight should be greater than 0")
    item.set_property(KEY_WEIGHT, new_weight)
#endregion
#endregion