extends Object

class_name Item

# Enum for item types
enum ItemType {
	WEAPON,
	ARMOR,
	CONSUMABLE,
	LOOT,
	OTHER
}

# Properties
var name: String = ""
var description: String = ""
var icon: Texture
var item_type: ItemType
var value: int  # Value of the item
var stack_size: int  # Maximum stack size for the item
var stack_count: int  # Current number of items in the stack

# Constructor
func _init(name: String, description: String, icon: Texture, item_type: ItemType, value: int = 0, stack_size: int = 1):
	self.name = name
	self.description = description
	self.icon = icon
	self.item_type = item_type
	self.value = value
	self.stack_size = stack_size
	self.stack_count = 1

# Getters
func get_name() -> String:
	return name

func get_description() -> String:
	return description

func get_icon() -> Texture:
	return icon

func get_item_type() -> ItemType:
	return item_type

func get_value() -> int:
	return value

func get_stack_size() -> int:
	return stack_size

func get_stack_count() -> int:
	return stack_count

# Setters
func set_name(new_name: String):
	name = new_name

func set_description(new_description: String):
	description = new_description

func set_icon(new_icon: Texture):
	icon = new_icon

func set_item_type(new_type: ItemType):
	item_type = new_type

func set_value(new_value: int):
	value = new_value

func set_stack_size(new_size: int):
	stack_size = new_size

func set_stack_count(new_count: int):
	stack_count = new_count

# Function to increase stack count
func increase_stack_count(amount: int):
	stack_count += amount
	if stack_count > stack_size:
		stack_count = stack_size

# Function to decrease stack count
func decrease_stack_count(amount: int):
	stack_count -= amount
	if stack_count < 0:
		stack_count = 0
