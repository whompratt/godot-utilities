extends Node

class_name PlayerInventoryScene

@onready var inventoryGrid: GridContainer = $GridContainer

func _ready():
	var playerInventory = PlayerInventory.new(inventoryGrid)
	add_child(playerInventory)

	# Example items in the player's inventory
	var items = [
		Item.new("Sword", "A sharp blade for combat.", null, Item.ItemType.WEAPON),
		Item.new("Armor", "Protective gear.", null, Item.ItemType.ARMOR),
		Item.new("Health Potion", "Restores 50 health points.", null, Item.ItemType.CONSUMABLE)
	]

	# Add items to the player inventory
	for item in items:
		playerInventory.add_item(item)

	# Update the inventory UI
	playerInventory.update_inventory_ui()

	# Connect signals
#	playerInventory.connect("item_selected", self, "_on_item_selected")

# Handle when an item is selected
func _on_item_selected(item: Item):
	# Do something when an item is selected
	print("Selected item:", item.get_name())
