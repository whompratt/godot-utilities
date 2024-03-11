extends Control

class_name Slot
signal item_clicked(item: Item, slotIndex: int, slotType: SlotType)

enum SlotType {
	HOTBAR,
	INVENTORY,
	STORAGE,
	SHOP
}

var item: Item = null
var slotType: SlotType
var itemInstance  # Reference to the Item child

func _ready():
	set_process_input(true)
	
	# Load and add the Item scene as a child
	var itemScene = preload("res://GodotUI-Scripts-Library/Scripts/ITEM/item.tscn")
	itemInstance = itemScene.instantiate()
	add_child(itemInstance)
	itemInstance.visible = false
	print("Item Instance:", itemInstance)
	# Connect signals from the Item child
	if itemInstance:
		itemInstance.connect("item_clicked", Callable(self, "_on_item_clicked"))

func set_item(new_item: Item):
	item = new_item
	update_item_ui()

func update_item_ui():
	print("Updating Item UI for:", item.get_item_name())
	if itemInstance:
		print("Item Instance found:", itemInstance)
		if item:
			itemInstance.visible = true
			itemInstance.set_item_name(item.get_item_name())
			itemInstance.set_description(item.get_description())
			itemInstance.set_icon(item.get_icon())
		else:
			itemInstance.visible = false
	else:
		print("Item Instance not found!")

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
		emit_signal("item_clicked", item, get_slot_index(), slotType)

func right_click():
	if item:
		print("Right-clicked on slot with item:", item, "Slot Type:", slotType)

func get_slot_index() -> int:
	# This function should return the slot index of this Slot
	# Implement based on your setup
	return 0
