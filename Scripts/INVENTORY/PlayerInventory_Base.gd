extends Inventory

class_name PlayerInventory

var weapon_slot: Item = null
var armor_slot: Item = null
var inventoryGrid: GridContainer



# Constructor
func _init(inventory_grid: GridContainer):
	inventoryGrid = inventory_grid

# Equip a weapon
func equip_weapon(weapon: Item):
	weapon_slot = weapon

# Equip armor
func equip_armor(armor: Item):
	armor_slot = armor

# Get equipped weapon
func get_equipped_weapon() -> Item:
	return weapon_slot

# Get equipped armor
func get_equipped_armor() -> Item:
	return armor_slot

# Override add_item to handle equipment slots
func add_item(item: Item) -> bool:
	if item.get_item_type() == Item.ItemType.WEAPON:
		if weapon_slot == null:
			weapon_slot = item
			emit_signal("item_selected", item)  # Emit signal when item is equipped
			return true
	elif item.get_item_type() == Item.ItemType.ARMOR:
		if armor_slot == null:
			armor_slot = item
			emit_signal("item_selected", item)  # Emit signal when item is equipped
			return true

	return super.add_item(item)

# Update inventory UI
func update_inventory_ui():
	inventoryGrid.clear()

	var items = get_all_items()

	for item in items:
		var inventoryItemScene = preload("res://GodotUI-Scripts-Library/Scripts/ITEM/item.gd")
		var inventoryItemInstance = inventoryItemScene.instantiate()
		inventoryItemInstance.item = item
		inventoryGrid.add_child(inventoryItemInstance)
