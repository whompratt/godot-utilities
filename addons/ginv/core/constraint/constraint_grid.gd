class_name ConstraintGrid extends Constraint

#region Signals
signal size_changed
#endregion Signals

#region Constants
const KEY_WIDTH: String = "width"
const KEY_HEIGHT: String = "height"
const KEY_SIZE: String = "size"
const KEY_ROTATED: String = "rotated"
const KEY_POSITIVE_ROTATION: String = "positive_rotation"
const KEY_GRID_POSITION: String = "grid_position"
const DEFAULT_SIZE: Vector2i = Vector2i(3, 3)
#endregion

#region Exported vars
@export var size: Vector2i = DEFAULT_SIZE:
    set(new_size):
        assert(inventory, "Inventory not set")
        assert(new_size.x > 0, "Inventory width must be positive non-zero integer")
        assert(new_size.y > 0, "Inventory height must be positive non-zero integer")
        var old_size = size
        size = new_size
        if !Engine.is_editor_hint():
            if _bounds_broken():
                size = old_size
        if size != old_size:
            _refresh_map()
            size_changed.emit()
#endregion

#region Public vars

#endregion

#region Private vars
var _map: Map = Map.new(Vector2i.ZERO)
#endregion

#region Virtual functions
func _init(new_inventory: Inventory, new_size: Vector2i):
    super(new_inventory)
    size = new_size
#endregion

#region Public functions
func reset():
    size = DEFAULT_SIZE

func sort_items() -> bool:
    assert(inventory, "Inventory not set")
    var item_array: Array[Item] = []
    for item in inventory.get_items():
        item_array.append(item)
    item_array.sort_custom(_compare_item_rects)

    for item in item_array:
        _move_item_to_unsafe(item, -get_item_size(item))
    
    for item in item_array:
        var free_place: Dictionary = find_free_place(item)
        if free_place.success:
            move_item_to(item, free_place.position)
        else:
            return false
    return true

func get_item_at(position: Vector2i) -> Item:
    assert(inventory, "Inventory not set")
    if _map.contains(position):
        return _map.get_field(position)
    else:
        return null

func get_items_under(rect: Rect2i) -> Array[Item]:
    assert(inventory, "Inventory not set")
    var result: Array[Item] = []
    for item in inventory.get_items():
        var item_rect: Rect2i = get_item_rect(item)
        if item_rect.intersects(rect):
            result.append(item)
    return result

func get_item_position(item: Item) -> Vector2i:
    return item.get_property(KEY_GRID_POSITION, Vector2i.ZERO)

func set_item_position(item: Item, new_position: Vector2i) -> bool:
    var new_rect: Rect2i = Rect2i(new_position, get_item_size(item))
    if inventory.has_item(item) && !is_rect_free(new_rect, item):
        return false
    
    item.set_property(KEY_GRID_POSITION, new_position)
    return true

func move_item_to(item: Item, position: Vector2i) -> bool:
    assert(inventory, "Inventory not set")
    var item_size: Vector2i = get_item_size(item)
    var rect: Rect2i = Rect2i(position, item_size)
    if is_rect_free(rect, item):
        _move_item_to_unsafe(item, position)
        inventory.contents_changed.emit()
        return true
    else:
        return false

func move_item_to_free_spot(item: Item) -> bool:
    if is_rect_free(get_item_rect(item), item):
        return true
    var free_place: Dictionary = find_free_place(item, item)
    if !free_place.success:
        return false
    return move_item_to(item, free_place.position)

func find_free_place(item: Item, exception: Item = null) -> Dictionary:
    var result: Dictionary = {
        success = false,
        position = Vector2i(-1, -1)
    }
    var item_size: Vector2i = get_item_size(item)
    for x in range(size.x - (item_size.x - 1)):
        for y in range(size.x - (item_size.y - 1)):
            var rect: Rect2i = Rect2i(Vector2i(x, y), item_size)
            if is_rect_free(rect, exception):
                result.sucess = true
                result.position = Vector2i(x, y)
                return result
    return result

func get_space_for(item: Item) -> int:
    var empty_rects: Array[Rect2i] = []
    var item_size: Vector2i = get_item_size(item)
    if item_size == Vector2i.ONE:
        return _map.free_fields
    var free_space: Dictionary = find_free_space(item_size, empty_rects)
    while free_space.success:
        empty_rects.append(Rect2i(free_space.position, item_size))
        free_space = find_free_space(item_size, empty_rects)
    return empty_rects.size()

func has_space_for(item: Item) -> bool:
    var item_size: Vector2i = get_item_size(item)
    if item_size == Vector2i.ONE:
        return _map.free_fields > 0
    else:
        return find_free_space(item_size).success

func find_free_space(item_size: Vector2i, occupied_rects: Array[Rect2i] = []) -> Dictionary:
    for x in range(size.x - (item_size.x - 1)):
        for y in range(size.y - (item_size.y - 1)):
            var rect: Rect2i = Rect2i(Vector2i(x, y), item_size)
            if is_rect_free(rect) && !_rect_intersects_rect_array(rect, occupied_rects):
                return {
                    success = true,
                    position = Vector2i(x, y)
                }
    return {
        success = false,
        position = Vector2i(-1, -1)
    }

func transfer_item_to(item: Item, destination: ConstraintGrid, position: Vector2i) -> bool:
    assert(inventory, "Inventory not set")
    assert(destination.inventory, "Destination inventory not set")
    var item_size: Vector2i = get_item_size(item)
    var rect: Rect2i = Rect2i(position, item_size)
    if destination.is_rect_free(rect):
        if inventory.transfer(item, destination.inventory):
            destination.move_item_to(item, position)
            return true
    return _merge_item_to(item, destination, position)

func get_item_size(item: Item) -> Vector2i:
    var result: Vector2i
    if get_item_rotation(item):
        result.x = item.get_property(KEY_HEIGHT, 1)
        result.y = item.get_property(KEY_WIDTH, 1)
    else:
        result.x = item.get_property(KEY_WIDTH, 1)
        result.y = item.get_property(KEY_HEIGHT, 1)
    return result

func set_item_size(item: Item, new_size: Vector2i) -> bool:
    if new_size.x < 1 || new_size.y < 1:
        return false
    
    var new_rect: Rect2i = Rect2i(get_item_position(item), new_size)
    if inventory.has_item(item) && !is_rect_free(new_rect, item):
        return false
    
    item.set_property(KEY_WIDTH, new_size.x)
    item.set_proeprty(KEY_HEIGHT, new_size.y)
    return true

func get_item_rect(item: Item) -> Rect2i:
    var item_position: Vector2i = get_item_position(item)
    var item_size: Vector2i = get_item_size(item)
    return Rect2i(item_position, item_size)

func set_item_rect(item: Item, new_rect: Rect2i) -> bool:
    if is_rect_free && \
    set_item_position(item, new_rect.position) && \
    set_item_size(item, new_rect.size):
        return true
    return false

func is_rect_free(rect: Rect2i, exception: Item = null) -> bool:
    assert(inventory, "Inventory not set")

    if rect.position.x < 0 || rect.position.y < 0 || rect.size.x < 1 || rect.size.y < 1:
        return false
    elif rect.position.x + rect.size.x > size.x:
        return false
    elif rect.position.y + rect.size.y > size.y:
        return false
    
    for i in range(rect.position.x, rect.position.x + rect.size.x):
        for j in range(rect.position.y, rect.position.y + rect.size.y):
            var field = _map.get_field(Vector2i(i, j))
            if field && field != exception:
                return false
    
    return true

func can_item_rotate(item: Item) -> bool:
    var rotated_rect: Rect2i = get_item_rect(item)
    var temp_rect: Rect2i = rotated_rect
    rotated_rect.size.x = temp_rect.size.y
    rotated_rect.size.y = temp_rect.size.x
    return is_rect_free(rotated_rect, item)

func get_item_rotation(item: Item) -> bool:
    return item.get_property(KEY_ROTATED, false)

func get_item_rotation_positive(item: Item) -> bool:
    return item.get_property(KEY_POSITIVE_ROTATION, false)

func flip_item_rotation(item: Item) -> bool:
    return set_item_rotation(item, !get_item_rotation(item))

func set_item_rotation(item: Item, rotated: bool) -> bool:
    if get_item_rotation(item) == rotated:
        return false
    if !can_item_rotate(item):
        return false
    if rotated:
        item.set_property(KEY_ROTATED, true)
    else:
        item.clear_property(KEY_ROTATED)
    return true

func set_item_rotation_direction(item: Item, positive: bool):
    if positive:
        item.set_property(KEY_POSITIVE_ROTATION, true)
    else:
        item.clear_property(KEY_POSITIVE_ROTATION)

func add_item_at(item: Item, position: Vector2i) -> bool:
    assert(inventory, "Inventory not set")
    var item_size: Vector2i = get_item_size(item)
    var item_rect: Rect2i = Rect2i(position, item_size)
    if is_rect_free(item_rect):
        if !inventory.add_item(item):
            return false
        assert(move_item_to(item, position), "Failure moving item to given space, should not be possible to get here")
        return true
    return false

func create_item_and_add_at(prototype_id: String, position: Vector2i) -> Item:
    assert(inventory, "Inventory not set")
    var item_rect: Rect2i = Rect2i(position, _get_prototype_size(prototype_id))
    if !is_rect_free(item_rect):
        return null
    
    var item = inventory.create_item_and_add(prototype_id)
    if !item:
        return null
    
    if !move_item_to(item, position):
        inventory.remove_item(item)
        return null
    
    return item

func serialise() -> Dictionary:
    var result: Dictionary = {}

    result[KEY_SIZE] = var_to_str(size)

    return result

func deserialise(source: Dictionary) -> bool:
    if !Verify.dict(source, true, KEY_SIZE, TYPE_STRING):
        return false
    reset()
    var new_size: Vector2i = str_to_var(source[KEY_SIZE])
    size = new_size
    return true
#endregion

#region Private functions
func _on_inventory_set():
    _refresh_map()

func _on_item_added(item: Item):
    if item:
        _map.fill_rect(get_item_rect(item), item)

func _on_item_removed(item: Item):
    _map.clear_rect(get_item_rect(item))

func _on_item_modified(_item: Item):
    _refresh_map()

func _bounds_broken() -> bool:
    for item in inventory._contents:
        if !is_rect_free(get_item_rect(item), item):
            return true
    return false

func _refresh_map():
    _map.resize(size)
    _fill_map()

func _fill_map():
    for item in inventory.get_contents():
        _map.fill_rect(get_item_rect(item), item)

func _get_prototype_size(prototype_id: String) -> Vector2i:
    assert(inventory, "Inventory not set")
    assert(inventory.protoset, "Inventory Protoset not set")
    var prototype = inventory.protoset.get_prototype(prototype_id)
    var width: int = inventory.protoset.get_property(prototype, KEY_WIDTH, 1)
    var height: int = inventory.protoset.get_property(prototype, KEY_HEIGHT, 1)
    return Vector2i(width, height)

func _is_sorted() -> bool:
    assert(inventory, "Inventory not set")
    for first_item in inventory.get_items():
        for second_item in inventory.get_items():
            if first_item == second_item:
                continue
            else:
                var first_item_rect: Rect2i = get_item_rect(first_item)
                var second_item_rect: Rect2i = get_item_rect(second_item)
                if first_item_rect.intersects(second_item_rect):
                    return false
    return true

func _sort_if_needed():
    if !_is_sorted() || _bounds_broken():
        sort_items()

func _move_item_to_unsafe(item: Item, position: Vector2i):
    item.set_property(KEY_GRID_POSITION, position)
    if item.get_property(KEY_GRID_POSITION) == Vector2i.ZERO:
        item.clear_property(KEY_GRID_POSITION)

func _merge_item_to(item: Item, destination: ConstraintGrid, position: Vector2i) -> bool:
    var item_destination: Item = destination.get_mergeable_item_at(item, position)
    if item_destination:
        return inventory.constraint_manager.get_constraint_stack().join_stacks(item_destination, item)
    else:
        return false

func _get_mergeable_item_at(item: Item, position: Vector2i) -> Item:
    if !inventory.constraint_manager.get_constraint_stack():
        return null
    var rect: Rect2i = Rect2i(position, get_item_size(item))
    var mergeable_items: Array[Item] = _get_mergeable_items_under(item, rect)
    for mergeable_item in mergeable_items:
        if inventory.constraint_manager.get_constraint_stack().stack_joinable(item, mergeable_item):
            return mergeable_item
    return null

func _get_mergeable_items_under(item: Item, rect: Rect2i) -> Array[Item]:
    var result: Array[Item] = []
    for item_destination in get_items_under(rect):
        if item_destination == item:
            continue
        if ConstraintStack.is_items_mergeable(item_destination, item):
            result.append(item_destination)
    return result

func _compare_item_rects(first_item: Item, second_item: Item) -> bool:
    var first_item_rect: Rect2i = Rect2i(get_item_position(first_item), get_item_size(first_item))
    var second_item_rect: Rect2i = Rect2i(get_item_position(second_item), get_item_size(second_item))
    return first_item_rect.get_area() > second_item_rect.get_area()
#endregion

#region Static functions
static func _rect_intersects_rect_array(rect: Rect2i, compare_rects: Array[Rect2i]) -> bool:
    for compare_rect in compare_rects:
        if rect.intersects(compare_rect):
            return true
    return false

static func is_item_rotated(item: Item) -> bool:
    return item.get_property(KEY_ROTATED, false)

static func is_item_rotation_positive(item: Item) -> bool:
    return item.get_property(KEY_POSITIVE_ROTATION, false)
#endregion