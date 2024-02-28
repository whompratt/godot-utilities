extends Control

# Enum for item types
enum ItemType {
	WEAPON,
	ARMOR,
	CONSUMABLE,
	LOOT,
	OTHER
}

# Properties
var _name: String = ""
var description: String = ""
var icon: Texture2D
var item_type: ItemType
var value: int  # Value of the item
var stack_size: int  # Maximum stack size for the item
var stack_count: int  # Current number of items in the stack


# Getters
func get_item_name() -> String:
	return _name

func get_description() -> String:
	return description

func get_icon() -> Texture2D:
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
func set_item_name(new_name: String):
	_name = new_name
	$ItemName.text = new_name

func set_description(new_description: String):
	description = new_description

func set_icon(new_icon: Texture2D):
	icon = new_icon

func set_item_type(new_type: ItemType):
	item_type = new_type

func set_value(new_value: int):
	value = new_value

func set_stack_size(new_size: int):
	stack_size = new_size

func set_stack_count(new_count: int):
	stack_count = new_count
	$ItemQuant.text = str(new_count)
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

# Function to create a drag preview for the item
func create_drag_preview() -> Control:
	var drag_preview = Control.new()
	drag_preview.rect_size = Vector2(64, 64)  # Size of the drag preview
	var icon_sprite = TextureRect.new()
	icon_sprite.texture = icon
	icon_sprite.rect_size = Vector2(64, 64)  # Size of the icon
	drag_preview.add_child(icon_sprite)
	return drag_preview
