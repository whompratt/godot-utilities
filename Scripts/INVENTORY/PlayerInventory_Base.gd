extends Inventory

class_name PlayerInventory

var weapon_slot: Item = null
var armor_slot: Item = null
var PlayerinventoryGrid: GridContainer

# Constructor
func _init(inventory_grid: GridContainer):
	PlayerinventoryGrid = inventory_grid
	connect("item_added", Callable(self, "_on_item_added"))
	connect("item_removed", Callable(self, "_on_item_removed"))

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
func add_item(item: Item, slotIndex: int) -> bool:
	if item.get_item_type() == Item.ItemType.WEAPON:
		if weapon_slot == null:
			weapon_slot = item
			emit_signal("item_added", item, slotIndex)
			return true
	elif item.get_item_type() == Item.ItemType.ARMOR:
		if armor_slot == null:
			armor_slot = item
			emit_signal("item_added", item, slotIndex)
			return true

	return super.add_item(item, slotIndex)
