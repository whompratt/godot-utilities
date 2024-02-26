extends Object

class_name Inventory

const GRID_COLS = 4
var items: Array = []  # Array to store items
var max_capacity: int = GRID_COLS * 4  # Maximum number of items the inventory can hold

# Signals
signal item_selected(item: Item)

# Constructor
func _init():
	pass

# Add an item to the inventory
func add_item(item: Item) -> bool:
	if item.get_stack_count() > 1:
		return add_stackable_item(item)
	elif items.size() < max_capacity:
		items.append(item)
		emit_signal("item_selected", item)  # Emit signal when item is added
		return true
	else:
		return false

# Add a stackable item to the inventory
func add_stackable_item(item: Item) -> bool:
	for i in range(items.size()):
		var stackable_item = items[i]
		if stackable_item.get_name() == item.get_name() and stackable_item.get_stack_count() < stackable_item.get_stack_size():
			stackable_item.increase_stack_count(item.get_stack_count())
			emit_signal("item_selected", item)  # Emit signal when item is added
			return true

	if items.size() < max_capacity:
		items.append(item)
		emit_signal("item_selected", item)  # Emit signal when item is added
		return true
	else:
		return false

# Remove an item from the inventory
func remove_item(item: Item) -> bool:
	var index = items.find(item)
	if index != -1:
		items.erase(index)
		return true
	else:
		return false

# Check if an item is in the inventory
func has_item(item: Item) -> bool:
	return items.has(item)

# Get total number of items in the inventory
func get_total_item_count() -> int:
	return items.size()

# Get all items in the inventory
func get_all_items() -> Array:
	return items
