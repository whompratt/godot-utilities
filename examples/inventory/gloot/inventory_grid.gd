@tool
extends GlootInventory
class_name GlootInventoryGrid

signal size_changed

const DEFAULT_SIZE: Vector2i = Vector2i(10, 10)

@export var size: Vector2i = DEFAULT_SIZE :
	get:
		if _constraint_manager == null:
			return DEFAULT_SIZE
		if _constraint_manager.get_grid_constraint() == null:
			return DEFAULT_SIZE
		return _constraint_manager.get_grid_constraint().size
	set(new_size):
		_constraint_manager.get_grid_constraint().size = new_size


func _init() -> void:
	super._init()
	_constraint_manager.enable_grid_constraint()
	_constraint_manager.get_grid_constraint().size_changed.connect(func(): size_changed.emit())


func get_item_position(item: GlootInventoryItem) -> Vector2i:
	return _constraint_manager.get_grid_constraint().get_item_position(item)


func get_item_size(item: GlootInventoryItem) -> Vector2i:
	return _constraint_manager.get_grid_constraint().get_item_size(item)


func get_item_rect(item: GlootInventoryItem) -> Rect2i:
	return _constraint_manager.get_grid_constraint().get_item_rect(item)


func set_item_rotation(item: GlootInventoryItem, rotated: bool) -> bool:
	return _constraint_manager.get_grid_constraint().set_item_rotation(item, rotated)


func rotate_item(item: GlootInventoryItem) -> bool:
	return _constraint_manager.get_grid_constraint().rotate_item(item)


func is_item_rotated(item: GlootInventoryItem) -> bool:
	return _constraint_manager.get_grid_constraint().is_item_rotated(item)


func can_rotate_item(item: GlootInventoryItem) -> bool:
	return _constraint_manager.get_grid_constraint().can_rotate_item(item)


func set_item_rotation_direction(item: GlootInventoryItem, positive: bool) -> void:
	_constraint_manager.set_item_rotation_direction(item, positive)


func is_item_rotation_positive(item: GlootInventoryItem) -> bool:
	return _constraint_manager.get_grid_constraint().is_item_rotation_positive(item)


func add_item_at(item: GlootInventoryItem, position: Vector2i) -> bool:
	return _constraint_manager.get_grid_constraint().add_item_at(item, position)


func create_and_add_item_at(prototype_id: String, position: Vector2i) -> GlootInventoryItem:
	return _constraint_manager.get_grid_constraint().create_and_add_item_at(prototype_id, position)


func get_item_at(position: Vector2i) -> GlootInventoryItem:
	return _constraint_manager.get_grid_constraint().get_item_at(position)


func get_items_under(rect: Rect2i) -> Array[GlootInventoryItem]:
	return _constraint_manager.get_grid_constraint().get_items_under(rect)


func move_item_to(item: GlootInventoryItem, position: Vector2i) -> bool:
	return _constraint_manager.get_grid_constraint().move_item_to(item, position)


func transfer_to(item: GlootInventoryItem, destination: GlootInventory, position: Vector2i) -> bool:
	return _constraint_manager.get_grid_constraint().transfer_to(item, destination._constraint_manager.get_grid_constraint(), position)


func rect_free(rect: Rect2i, exception: GlootInventoryItem = null) -> bool:
	return _constraint_manager.get_grid_constraint().rect_free(rect, exception)


func find_free_place(item: GlootInventoryItem) -> Dictionary:
	return _constraint_manager.get_grid_constraint().find_free_place(item)


func sort() -> bool:
	return _constraint_manager.get_grid_constraint().sort()

