extends 'res://GodotUI-Scripts-Library/Scripts/ITEM/Item_Base.gd'

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
var healing_amount: int  # Could represent healing amount, mana restored, etc.

# Constructor
func _init(name: String, description: String, icon: Texture, item_type: ItemType, effect: String, healing_amount: int):
	super._init(name, description, icon, item_type)
	self.effect = effect
	self.healing_amount = healing_amount

# Getter for effect
func get_effect() -> String:
	return effect

# Getter for healing amount
func get_healing_amount() -> int:
	return healing_amount

# Setter for effect
func set_effect(new_effect: String):
	effect = new_effect

# Setter for healing amount
func set_healing_amount(new_healing_amount: int):
	healing_amount = new_healing_amount
