extends Control

class_name Slot

enum SlotType {
	HOTBAR,
	INVENTORY,
	STORAGE,
	SHOP
}

var item: Item = null
var slotType: SlotType
var itemDisplay: Control

func _init(slot_type: SlotType = SlotType.INVENTORY):
	slotType = slot_type

func _ready():
	set_process_input(true)
	
	# Load and add the Item scene as a child
	var itemScene = preload("res://GodotUI-Scripts-Library/Scripts/ITEM/item.tscn")
	itemDisplay = itemScene.instantiate()
	add_child(itemDisplay)
	itemDisplay.visible = false

func set_item(new_item: Item):
	item = new_item
	update_item_ui()

func update_item_ui():
	if item:
		itemDisplay.visible = true
		# Update item properties in itemDisplay
		itemDisplay.set_item_name(item.get_item_name())
		itemDisplay.set_description(item.get_description())
		itemDisplay.set_icon(item.get_icon())
	else:
		itemDisplay.visible = false

func _process(delta):
	if is_mouse_over():
		# Implement hover effect if needed
		pass

func is_mouse_over() -> bool:
	var mouse_pos = get_local_mouse_position()
	return global_position.distance_to(mouse_pos) < size.x / 2  

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
			left_click()
		elif event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed():
			right_click()

func left_click():
	if item:
		print("Left-clicked on slot with item:", item, "Slot Type:", slotType)

func right_click():
	if item:
		print("Right-clicked on slot with item:", item, "Slot Type:", slotType)
