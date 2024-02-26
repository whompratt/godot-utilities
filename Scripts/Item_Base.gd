extends Object
class_name Item
enum ItemType {
	WEAPON,
	LOOT,
	CONSUMABLE,
	OTHER
}



## Creating instances of different item types
#var sword: Item = Item.new("Sword", "A sharp blade for combat.", preload("res://textures/sword_icon.png"), ItemType.WEAPON)
#var goldCoin: Item = Item.new("Gold Coin", "Shiny gold coin.", preload("res://textures/gold_coin_icon.png"), ItemType.LOOT)
#var healthPotion: Item = Item.new("Health Potion", "Restores 50 health points.", preload("res://textures/health_potion_icon.png"), ItemType.CONSUMABLE)
#var otherItem: Item = Item.new("Other Item", "Some other type of item.", preload("res://textures/other_icon.png"), ItemType.OTHER)

## Accessing properties
#var itemName: String = sword.get_name()
#var itemDescription: String = sword.get_description()
#var itemIcon: Texture = sword.get_icon()
#var itemType: ItemType = sword.get_item_type()

## Modifying properties (if setters are needed)
#sword.set_name("Legendary Sword")

# Item properties
var name: String = ""
var description: String = ""
var icon: Texture
var item_type: ItemType

# Constructor
func _init(name: String, description: String, icon: Texture, item_type: ItemType):
	self.name = name
	self.description = description
	self.icon = icon
	self.item_type = item_type

# Getters
func get_name() -> String:
	return name

func get_description() -> String:
	return description

func get_icon() -> Texture:
	return icon

func get_item_type() -> ItemType:
	return item_type

# Setters (optional, depending on needs)
func set_name(new_name: String):
	name = new_name

func set_description(new_description: String):
	description = new_description

func set_icon(new_icon: Texture):
	icon = new_icon

func set_item_type(new_type: ItemType):
	item_type = new_type
