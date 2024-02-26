extends 'res://GodotUI-Scripts-Library/Scripts/Item_Base.gd'

class_name Loot

## Creating a Loot instance
#var goldCoin: Loot = Loot.new("Gold Coin", "Shiny gold coin.", preload("res://textures/gold_coin_icon.png"), ItemType.LOOT, 10, 0.01)

## Accessing properties
#var lootName: String = goldCoin.get_name()
#var lootDescription: String = goldCoin.get_description()
#var lootIcon: Texture = goldCoin.get_icon()
#var lootType: ItemType = goldCoin.get_item_type()
#var lootValue: int = goldCoin.get_value()
#var lootWeight: float = goldCoin.get_weight()

# Modifying properties (if setters are needed)
#goldCoin.set_name("Diamond")
#goldCoin.set_value(100)
#goldCoin.set_weight(0.05)

# Loot properties (in addition to Item properties)
var value: int
var weight: float

# Constructor
func _init(name: String, description: String, icon: Texture, item_type: ItemType, value: int, weight: float):
	super._init(name, description, icon, item_type)
	self.value = value
	self.weight = weight

# Getter for value
func get_value() -> int:
	return value

# Getter for weight
func get_weight() -> float:
	return weight

# Setter for value
func set_value(new_value: int):
	value = new_value

# Setter for weight
func set_weight(new_weight: float):
	weight = new_weight
