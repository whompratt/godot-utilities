extends Control

@export var itemIcon: TextureRect
@export var itemName:Label
@export var itemQuant:Label
const Item = preload("res://GodotUI-Scripts-Library/Scripts/ITEM/Item_Base.gd")
# Reference to UI elements

var item: Item = null

func _ready():
	# Get references to UI elements
	assert(itemIcon, "An itemIcon must be set.")
	assert(itemName, "An itemName must be set.")
	assert(itemQuant, "An itemQuant must be set.")
	# Update UI with item data
	update_item_ui()

func set_item(item_data: Item):
	item = item_data
	update_item_ui()

func update_item_ui():
	if item:
		itemIcon.texture = item.get_icon()
		itemName.text = item.get_name()
		itemQuant.text = str(item.get_stack_count())
	else:
		itemIcon.texture = null
		itemName.text = ""
		itemQuant.text = ""
