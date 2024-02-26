extends Control

var item: Item

# Reference to UI elements
var itemIcon: TextureRect
var itemName: Label
var itemQuant: Label

func _ready():
	# Get references to UI elements
	itemIcon = $ItemIcon
	itemName = $ItemName
	itemQuant = $ItemQuant

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
