extends 'res://GodotUI-Scripts-Library/Scripts/ITEM/Item_Base.gd'

class_name Weapon

## Creating a Weapon instance
#var sword: Weapon = Weapon.new("Sword", "A sharp blade for combat.", preload("res://textures/sword_icon.png"), ItemType.WEAPON, 20, 1.2)

## Accessing properties
#var weaponName: String = sword.get_name()
#var weaponDescription: String = sword.get_description()
#var weaponIcon: Texture = sword.get_icon()
#var weaponType: ItemType = sword.get_item_type()
#var weaponDamage: int = sword.get_damage()
#var weaponAttackSpeed: float = sword.get_attack_speed()

## Modifying properties (if setters are needed)
#sword.set_name("Legendary Sword")
#sword.set_damage(30)

# Weapon properties (in addition to Item properties)
var damage: int
var attack_speed: float

# Constructor
func _init(name: String, description: String, icon: Texture, item_type: ItemType, damage: int, attack_speed: float):
	super._init(name, description, icon, item_type)
	self.damage = damage
	self.attack_speed = attack_speed

# Getter for damage
func get_damage() -> int:
	return damage

# Getter for attack speed
func get_attack_speed() -> float:
	return attack_speed

# Setter for damage
func set_damage(new_damage: int):
	damage = new_damage

# Setter for attack speed
func set_attack_speed(new_attack_speed: float):
	attack_speed = new_attack_speed
