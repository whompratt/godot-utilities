@tool
class_name InventoryGrid extends Inventory

#region Signals
signal size_changed
#endregion

#region Constants
const DEFAULT_SIZE: Vector2i = Vector2i(10, 10)
#endregion

#region Exported vars
@export var size: Vector2i = DEFAULT_SIZE:
    get:
        if !constraint_manager:
            return DEFAULT_SIZE
        elif !constraint_manager.get_grid_contraint():
            return DEFAULT_SIZE
        else:
            return constraint_manager.get_grid_constraint().size
    set(new_size):
        constraint_manager.get_grid_constraint().size = new_size
#endregion

#region Virtual functions
func _init():
    super._init()
    constraint_manager.enable_grid_constraint()
    constraint_manager.get_grid_constraint().size_changed.connext(func(): size_changed.emit())
#endregion

#region Public functions
func get_item_position(item: Item) -> Vector2i:
    return constraint_manager.get_grid_constraint().get_item_position(item)

func get_item_size(item: Item) -> Vector2i:
    return constraint_manager.get_grid_constraint().get_item_size(item)

func get_item_rect(item: Item) -> Rect2i:
    return constraint_manager.get_grid_constraint().get_item_rect(item)

func set_item_rotation(item: Item, rotated: bool) -> bool:
    return constraint_manager.get_grid_constraint().set_item_rotation(item, rotated)

func rotate_item(item: Item) -> bool:
    return constraint_manager.get_grid_constraint().rotate_item(item)

func is_item_rotated(item: Item) -> bool:
    return constraint_manager.get_grid_constraint().is_item_rotated(item)

func can_rotate_item(item: Item) -> bool:
    return constraint_manager.get_grid_constraint().can_rotate_item(item)

func set_item_rotation_direction(item: Item, positive: bool):
    constraint_manager.set_item_rotation_direction(item, positive)

func is_item_rotation_positive(item: Item) -> bool:
    return constraint_manager.get_grid_constraint().is_item_rotation_positive(item)

func add_item_at(item: Item, position: Vector2i) -> bool:
    return constraint_manager.get_grid_constraint().add_item_at(item, position)

func create_and_add_item_at(prototype_id: String, position: Vector2i) -> Item:
    return constraint_manager.get_grid_constraint().create_and_add_item_at(prototype_id, position)

func get_item_at(position: Vector2i) -> Item:
    return constraint_manager.get_grid_constraint().get_item_at(position)

func get_items_under(rect: Rect2i) -> Array[Item]:
    return constraint_manager.get_grid_constraint().get_items_under(rect)

func move_item_to(item: Item, position: Vector2i) -> bool:
    return constraint_manager.get_grid_constraint().move_item_to(item, position)

func transfer_to(item: Item, destination: Inventory, position: Vector2i) -> bool:
    return constraint_manager.get_grid_constraint().transfer_to(item, destination.constraint_manager.get_grid_constraint(), position)

func is_rect_free(rect: Rect2i, exception: Item = null) -> bool:
    return constraint_manager.get_grid_constraint().is_rect_free(rect, exception)

func find_free_place(item: Item) -> Dictionary:
    return constraint_manager.get_grid_constraint().find_free_place(item)

func sort() -> bool:
    return constraint_manager.get_grid_constraint().sort()
#endregion