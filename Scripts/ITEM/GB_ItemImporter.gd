extends GDScript

class_name ItemImporter

## Usage example
#func _ready():
#	var items = import_items_from_json("res://GodotUI-Scripts-Library/Scripts/ITEM/Test_Items.JSON")
#	for item in items:
#		print("Imported Item:", item.get_name(), "Description:", item.get_description(), "Type:", item.get_item_type())
#        match item:
#             is Weapon:
#                print("Damage:", item.get_damage(), "Attack Speed:", item.get_attack_speed())
#            is Loot:
#               print("Value:", item.get_value(), "Weight:", item.get_weight())
#           is Consumable:
#                print("Effect:", item.get_effect(), "Value:", item.get_value())
#            is OtherItem:
#                print("Custom Properties:", item.custom_properties)


# Import ItemType from Item script
const ItemType = preload('res://GodotUI-Scripts-Library/Scripts/ITEM/Item_Base.gd').ItemType


# Singleton instance
static var instance: ItemImporter

# Constructor (called when script is loaded)
func _init():
	instance = self

# Singleton function to get the instance
static func get_instance() -> ItemImporter:
	return instance

func import_items_from_json(json_file_path: String) -> Array:
	var items = []

	# Load JSON data
	var item_data = load_data(json_file_path)
	if item_data:
		for data in item_data:
			var name = data["name"]
			var description = data["description"]
			var icon_path = data["icon_path"]
			var item_type_str = data["item_type"]

			var item_type = match_item_type(item_type_str)

			var item

			match item_type:
				ItemType.WEAPON:
					var damage = data["damage"]
					var attack_speed = data["attack_speed"]
					item = Weapon.new(name, description, load_icon_texture(icon_path), item_type, damage, attack_speed)

				ItemType.LOOT:
					var value = data["value"]
					var weight = data["weight"]
					item = Loot.new(name, description, load_icon_texture(icon_path), item_type, value, weight)

				ItemType.CONSUMABLE:
					var effect = data["effect"]
					var value = data["value"]
					item = Consumable.new(name, description, load_icon_texture(icon_path), item_type, effect, value)

				ItemType.OTHER:
					var custom_properties = data["custom_properties"]
					item = OtherItem.new(name, description, load_icon_texture(icon_path), item_type)
					for key in custom_properties.keys():
						item.set_custom_property(key, custom_properties[key])

			if item:
				items.append(item)

	return items

func match_item_type(type_str: String) -> ItemType:
	match type_str:
		"WEAPON":
			return ItemType.WEAPON
		"LOOT":
			return ItemType.LOOT
		"CONSUMABLE":
			return ItemType.CONSUMABLE
		"OTHER":
			return ItemType.OTHER
		_:
			return ItemType.OTHER  # Default to OTHER if type is unrecognized

func load_icon_texture(icon_path: String) -> Texture:
	var texture = null
	var icon_resource = ResourceLoader.load(icon_path)
	if icon_resource is Texture:
		texture = icon_resource
	else:
		printerr("Icon not found or not a Texture:", icon_path)
	return texture

func load_data(file_path: String) -> Array:
	var json_data = JSON.new()
	var item_data = []
	var file_data = FileAccess.open(file_path, FileAccess.READ)
	var contents = file_data.get_as_text()
	json_data.parse(contents)
	
	
	item_data = json_data.get_data()
	
	

	return item_data
