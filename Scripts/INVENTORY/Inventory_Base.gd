extends Control

class_name Inventory

const GRID_COLS = 4
const GRID_ROWS = 4

var items: Array = []
var inventoryGrid: GridContainer
signal item_added(item: Item, slotIndex: int)
signal item_removed(item: Item, slotIndex: int)

# Constructor
func _init(inventory_grid: GridContainer):
	inventoryGrid = inventory_grid

func add_item(item: Item, slotIndex: int) -> bool:
	if slotIndex < 0 or slotIndex >= GRID_COLS * GRID_ROWS:
		return false

	if items.size() <= slotIndex:
		items.resize(slotIndex + 1)  # Resize and initialize with nulls

	if items[slotIndex] == null:
		items[slotIndex] = item
		emit_signal("item_added", item, slotIndex)
		return true
	else:
		return false

func remove_item(slotIndex: int) -> bool:
	if slotIndex < 0 or slotIndex >= GRID_COLS * GRID_ROWS:
		return false

	if items.size() > slotIndex and items[slotIndex] != null:
		var removed_item = items[slotIndex]
		items[slotIndex] = null
		emit_signal("item_removed", removed_item, slotIndex)
		return true
	else:
		return false

func is_slot_empty(slotIndex: int) -> bool:
	if slotIndex < 0 or slotIndex >= GRID_COLS * GRID_ROWS:
		return false

	return items.size() <= slotIndex or items[slotIndex] == null

func get_item_in_slot(slotIndex: int) -> Item:
	if slotIndex < 0 or slotIndex >= GRID_COLS * GRID_ROWS:
		return null

	if items.size() > slotIndex:
		return items[slotIndex]
	else:
		return null

func move_item(fromSlotIndex: int, toSlotIndex: int) -> bool:
	if fromSlotIndex < 0 or fromSlotIndex >= GRID_COLS * GRID_ROWS:
		return false

	if toSlotIndex < 0 or toSlotIndex >= GRID_COLS * GRID_ROWS:
		return false

	if items.size() > fromSlotIndex and items[fromSlotIndex] != null:
		var item = items[fromSlotIndex]
		items[fromSlotIndex] = null
		items[toSlotIndex] = item
		return true
	else:
		return false

# Updated function to update inventory UI
func update_inventory_ui(grid: GridContainer):
	grid.queue_free()

	for slotIndex in range(GRID_COLS * GRID_ROWS):
		var item = get_item_in_slot(slotIndex)
		if item != null:
			var slot = Slot.new()
			slot.set_item(item)  # Set the item in the slot
			grid.add_child(slot)
