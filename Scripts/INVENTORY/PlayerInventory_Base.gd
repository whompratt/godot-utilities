extends Inventory

class_name PlayerInventory

var weapon_slot: Item = null
var armor_slot: Item = null

# Constants
const WEAPON_SLOT_INDEX: int = 0
const ARMOR_SLOT_INDEX: int = 1

# Constructor
func _init():
	pass

# Equip a weapon
func equip_weapon(weapon: Item):
	if weapon.get_item_type() == Item.ItemType.WEAPON:
		weapon_slot = weapon
		emit_signal("item_added", weapon, WEAPON_SLOT_INDEX)

# Equip armor
func equip_armor(armor: Item):
	if armor.get_item_type() == Item.ItemType.ARMOR:
		armor_slot = armor
		emit_signal("item_added", armor, ARMOR_SLOT_INDEX)

# Get equipped weapon
func get_equipped_weapon() -> Item:
	return weapon_slot

# Get equipped armor
func get_equipped_armor() -> Item:
	return armor_slot

# Override add_item to handle equipment slots
func add_item(item: Item, slotIndex: int) -> bool:
	if slotIndex == WEAPON_SLOT_INDEX:
		equip_weapon(item)
		return true
	elif slotIndex == ARMOR_SLOT_INDEX:
		equip_armor(item)
		return true
	else:
		return super.add_item(item, slotIndex)

# Remove an item from the inventory
func remove_item(slotIndex: int) -> Item:
	if slotIndex == WEAPON_SLOT_INDEX:
		var weapon = weapon_slot
		weapon_slot = null
		emit_signal("item_removed", weapon, WEAPON_SLOT_INDEX)
		return weapon
	elif slotIndex == ARMOR_SLOT_INDEX:
		var armor = armor_slot
		armor_slot = null
		emit_signal("item_removed", armor, ARMOR_SLOT_INDEX)
		return armor
	else:
		return super.remove_item(slotIndex)
