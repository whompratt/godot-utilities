extends 'res://GodotUI-Scripts-Library/Scripts/ITEM/Item_Base.gd'

class_name OtherItem

## Creating an OtherItem instance
#var potion: OtherItem = OtherItem.new("Custom Potion", "A potion with custom properties.", preload("res://textures/potion_icon.png"), ItemType.OTHER)

## Set custom properties
#potion.set_custom_property("effect", "Enhances strength")
#potion.set_custom_property("duration", 60)
#potion.set_custom_property("rarity", "Rare")

## Accessing properties
#var otherItemName: String = potion.get_name()
#var otherItemDescription: String = potion.get_description()
#var otherItemIcon: Texture = potion.get_icon()
#var otherItemType: ItemType = potion.get_item_type()

## Getting custom properties
#var effect: String = potion.get_custom_property("effect")
#var duration: int = potion.get_custom_property("duration")
#var rarity: String = potion.get_custom_property("rarity")

## Checking if a custom property exists
#var hasRarity: bool = potion.has_custom_property("rarity")
#var hasQuantity: bool = potion.has_custom_property("quantity")

## Outputting values
#print("Other Item:", otherItemName)
#print("Description:", otherItemDescription)
#print("Icon:", otherItemIcon)
#print("Type:", otherItemType)
#print("Effect:", effect)
#print("Duration:", duration)
#print("Rarity:", rarity)
#print("Has Rarity:", hasRarity)  # true
#print("Has Quantity:", hasQuantity)  # false

# OtherItem properties (in addition to Item properties)
var custom_properties: Dictionary = {}

# Constructor
func _init(name: String, description: String, icon: Texture, item_type: ItemType):
	super._init(name, description, icon, item_type)

# Setter for custom properties
func set_custom_property(key: String, value: Variant):
	custom_properties[key] = value

# Getter for custom properties
func get_custom_property(key: String) -> Variant:
	return custom_properties[key] if custom_properties.has(key) else null

# Method to check if a custom property exists
func has_custom_property(key: String) -> bool:
	return custom_properties.has(key)
