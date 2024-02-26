extends 'res://scripts/Item.gd'

class_name Consumable

## Creating a Consumable instance (e.g., Health Potion)
#var healthPotion: Consumable = Consumable.new("Health Potion", "Restores 50 health points.", preload("res://textures/health_potion_icon.png"), ItemType.CONSUMABLE, "Heals", 50)

## Accessing properties
#var consumableName: String = healthPotion.get_name()
#var consumableDescription: String = healthPotion.get_description()
#var consumableIcon: Texture = healthPotion.get_icon()
#var consumableType: ItemType = healthPotion.get_item_type()
#var consumableEffect: String = healthPotion.get_effect()
#var consumableValue: int = healthPotion.get_value()

## Modifying properties (if setters are needed)
#healthPotion.set_name("Super Health Potion")
#healthPotion.set_value(100)

# Consumable properties (in addition to Item properties)
var effect: String
var value: int  # Could represent healing amount, mana restored, etc.

# Constructor
func _init(name: String, description: String, icon: Texture, item_type: ItemType, effect: String, value: int):
	super._init(name, description, icon, item_type)
	self.effect = effect
	self.value = value

# Getter for effect
func get_effect() -> String:
	return effect

# Getter for value
func get_value() -> int:
	return value

# Setter for effect
func set_effect(new_effect: String):
	effect = new_effect

# Setter for value
func set_value(new_value: int):
	value = new_value
