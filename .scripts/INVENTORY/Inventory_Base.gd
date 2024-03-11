extends Object

class_name Inventory

# Constants
const GRID_COLS: int = 5  # Number of columns in the grid

# Properties
var size: Vector2 = Vector2(GRID_COLS, 2)  # Size of the inventory grid
var items: Array
var inventoryGrid: GridContainer

# Signals
signal item_added(item: Item, slotIndex: int)
signal item_removed(item: Item, slotIndex: int)

# Constructor
func _init():
	items = []

# Initialize the inventory with a GridContainer
func initialize_inventory(grid: GridContainer):
	inventoryGrid = grid
	for i in range(size.x * size.y):
		var slot = inventoryGrid.get_child(i)
		slot.connect("item_added", Callable(self, "_on_slot_item_added"))
		slot.connect("item_removed", Callable(self, "_on_slot_item_removed"))

# Add an item to the inventory
func add_item(item: Item, slotIndex: int) -> bool:
	if items.size() <= slotIndex:
		items.resize(slotIndex + 1)
	
	if items[slotIndex] == null:
		items[slotIndex] = item
		emit_signal("item_added", item, slotIndex)
		return true
	
	return false

# Remove an item from the inventory
func remove_item(slotIndex: int) -> Item:
	if items.size() > slotIndex and items[slotIndex] != null:
		var item = items[slotIndex]
		items[slotIndex] = null
		emit_signal("item_removed", item, slotIndex)
		return item
	
	return null

# Get the item at a specific slot
func get_item_at_slot(slotIndex: int) -> Item:
	if items.size() > slotIndex:
		return items[slotIndex]
	
	return null

# Function to print inventory contents
func print_inventory_contents():
	for i in range(items.size()):
		var item = items[i]
		if item != null:
			print("Slot", i, ":", item.get_name(), "Quantity:", item.get_stack_count())
		else:
			print("Slot", i, ": Empty")

# Handle item added to a slot
func _on_slot_item_added(slotIndex: int, item: Item):
	add_item(item, slotIndex)

# Handle item removed from a slot
func _on_slot_item_removed(slotIndex: int, item: Item):
	remove_item(slotIndex)
