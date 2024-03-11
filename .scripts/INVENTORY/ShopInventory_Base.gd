extends Inventory

class_name ShopInventory

# Constructor
func _init():
	pass

# Override add_item to prevent adding items directly to shop inventory
func add_item(item: Item) -> bool:
	return false  # Prevent adding items directly to shop inventory

# Override remove_item to prevent removing items from shop inventory
func remove_item(item: Item) -> bool:
	return false  # Prevent removing items from shop inventory

# Function to buy an item from the shop
func buy_item(item: Item) -> bool:
	if has_item(item):
		return remove_item(item)
	else:
		return false

# Function to sell an item to the shop
func sell_item(item: Item) -> bool:
	return add_item(item)
