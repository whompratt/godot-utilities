class_name ConstraintManager extends RefCounted

#region Enums
enum Configuration {
    NORMAL,
    GRID,
    STACK,
    WEIGHT,
    GRID_STACK,
    GRID_WEIGHT,
    STACK_WEIGHT,
    GRID_STACK_WEIGHT,
}
#endregion

#region Constants
const KEY_CONSTRAINT_WEIGHT = "constraint_weight"
const KEY_CONSTRAINT_STACK = "constraint_stack"
const KEY_CONSTRAINT_GRID = "constraint_grid"
#endregion


#region Public vars
var inventory: Inventory = null:
    set(new_inventory):
        assert(new_inventory, "Cannot set inventory to null")
        assert(not inventory, "Inventory already set")
        inventory = new_inventory
        if _constraint_weight:
            _constraint_weight.inventory = inventory
        if _constraint_stack:
            _constraint_stack.inventory = inventory
        if _constraint_grid:
            _constraint_grid.inventory = inventory
#endregion

#region Private vars
var _constraint_weight: ConstraintWeight = null
var _constraint_stack: ConstraintStack = null
var _constraint_grid: ConstraintGrid = null
#endregion

#region Virtual functions
func _init(_inventory: Inventory):
    inventory = _inventory
#endregion

#region Public functions
func reset():
    if _constraint_grid:
        _constraint_grid.reset()
    if _constraint_stack:
        _constraint_stack.reset()
    if _constraint_weight:
        _constraint_weight.reset()

func get_configuration() -> int:
    if _constraint_grid && _constraint_stack && _constraint_weight:
        return Configuration.GRID_STACK_WEIGHT
    elif _constraint_grid && _constraint_stack:
        return Configuration.GRID_STACK
    elif _constraint_grid && _constraint_weight:
        return Configuration.GRID_WEIGHT
    elif _constraint_stack && _constraint_weight:
        return Configuration.STACK_WEIGHT
    elif _constraint_grid:
        return Configuration.GRID
    elif _constraint_stack:
        return Configuration.STACK
    elif _constraint_weight:
        return Configuration.WEIGHT
    else:
        return Configuration.NORMAL

func get_space_for(item: Item) -> int:
    match get_configuration():
        Configuration.GRID:
            return _constraint_grid.get_space_for(item)
        Configuration.STACK:
            return _constraint_stack.get_space_for(item)
        Configuration.WEIGHT:
            return _constraint_weight.get_space_for(item)
        Configuration.GRID_STACK:
            return _grid_stack_get_space_for(item)
        Configuration.GRID_WEIGHT:
            return min(_constraint_grid.get_space_for(item), _constraint_weight.get_space_for(item))
        Configuration.STACK_WEIGHT:
            return _stack_weight_get_space_for(item)
        Configuration.GRID_STACK_WEIGHT:
            return min(_grid_stack_get_space_for(item), _stack_weight_get_space_for(item))
        _:
            return Count.INF

func has_space_for(item: Item) -> bool:
    match get_configuration():
        Configuration.GRID:
            return _constraint_grid.has_space_for(item)
        Configuration.STACK:
            return _constraint_stack.has_space_for(item)
        Configuration.WEIGHT:
            return _constraint_weight.has_space_for(item)
        Configuration.GRID_STACK:
            return _grid_stack_has_space_for(item)
        Configuration.GRID_WEIGHT:
            return _constraint_weight.has_space_for(item) && _constraint_grid.has_space_for(item)
        Configuration.STACK_WEIGHT:
            return _constraint_weight.has_space_for(item)
        Configuration.GRID_STACK_WEIGHT:
            return _grid_stack_has_space_for(item) && _constraint_weight.has_space_for(item)
        _:
            return true

func enable_constraint_grid(size: Vector2i = ConstraintGrid.DEFAULT_SIZE):
    assert(!_constraint_grid, "Grid constraint already enabled")
    _constraint_grid = ConstraintGrid.new(inventory, size)

func enable_constraint_stack():
    assert(!_constraint_stack, "Stack constraint already enabled")
    _constraint_stack = ConstraintStack.new(inventory)

func enable_constraint_weight(capacity: float = 0.0):
    assert(!_constraint_weight, "Weight constraint already enabled")
    _constraint_weight = ConstraintWeight.new(inventory, capacity)

func get_constraint_grid() -> ConstraintGrid:
    return _constraint_grid

func get_constraint_stack() -> ConstraintStack:
    return _constraint_stack

func get_constraint_weight() -> ConstraintWeight:
    return _constraint_weight

func serialise() -> Dictionary:
    var result: Dictionary = {}

    if _constraint_grid:
        result[KEY_CONSTRAINT_GRID] = _constraint_grid.serialise()
    if _constraint_stack:
        result[KEY_CONSTRAINT_STACK] = _constraint_stack.serialise()
    if _constraint_weight:
        result[KEY_CONSTRAINT_WEIGHT] = _constraint_weight.serialise()
    
    return result

func deserialise(source: Dictionary) -> bool:
    if !Verify.dict(source, false, KEY_CONSTRAINT_GRID, TYPE_DICTIONARY):
        return false
    if !Verify.dict(source, false, KEY_CONSTRAINT_STACK, TYPE_DICTIONARY):
        return false
    if !Verify.dict(source, false, KEY_CONSTRAINT_WEIGHT, TYPE_DICTIONARY):
        return false
    
    reset()

    if source.has(KEY_CONSTRAINT_GRID):
        if !_constraint_grid.deserialise(source[KEY_CONSTRAINT_GRID]):
            return false
    if source.has(KEY_CONSTRAINT_STACK):
        if !_constraint_stack.deserialise(source[KEY_CONSTRAINT_STACK]):
            return false
    if source.has(KEY_CONSTRAINT_WEIGHT):
        if !_constraint_weight.deserialise(source[KEY_CONSTRAINT_WEIGHT]):
            return false
    return true
#endregion

#region Private functions
func _enforce_constraints(item: Item) -> bool:
    match get_configuration():
        Configuration.GRID:
            return _constraint_grid.move_item_to_free_spot(item)
        Configuration.GRID_STACK:
            return _constraint_grid.move_item_to_free_spot(item) || _constraint_stack.pack_item(item)
        Configuration.GRID_WEIGHT:
            return _constraint_grid.move_item_to_free_spot(item)
        Configuration.GRID_STACK_WEIGHT:
            return _constraint_grid.move_item_to_free_spot(item) || _constraint_stack.pack_item(item)
        _:
            return true

func _on_item_added(item: Item):
    assert(_enforce_constraints(item), "Failed to enfore inventory constraints")

    if _constraint_grid:
        _constraint_grid._on_item_added(item)
    if _constraint_stack:
        _constraint_stack._on_item_added(item)
    if _constraint_weight:
        _constraint_weight._on_item_added(item)

func _on_item_removed(item: Item):
    if _constraint_grid:
        _constraint_grid._on_item_removed(item)
    if _constraint_stack:
        _constraint_stack._on_item_removed(item)
    if _constraint_weight:
        _constraint_weight._on_item_removed(item)

func _on_item_modified(item: Item):
    if _constraint_grid:
        _constraint_grid._on_item_modified(item)
    if _constraint_stack:
        _constraint_stack._on_item_modified(item)
    if _constraint_weight:
        _constraint_weight._on_item_modified(item)

func _grid_stack_get_space_for(item: Item) -> int:
    var grid_space: int = _constraint_grid.get_space_for(item)
    var stack_size: int = ConstraintStack.get_item_stack_size(item)
    var max_stack_size: int = ConstraintStack.get_item_max_stack_size(item)
    var free_stack_space: int = _constraint_stack.get_free_stack_space_for(item)
    return ((grid_space * max_stack_size) + free_stack_space) / stack_size

func _grid_stack_has_space_for(item: Item) -> int:
    if _constraint_grid.has_space_for(item):
        return true
    var stack_size: int = ConstraintStack.get_item_stack_size(item)
    var stack_free_space: int = _constraint_stack.get_free_stack_space_for(item)
    return stack_free_space >= stack_size

func _stack_weight_get_space_for(item: Item) -> int:
    var stack_size: int = ConstraintStack.get_item_stack_size(item)
    return _constraint_weight.get_space_for(item) / stack_size
#endregion