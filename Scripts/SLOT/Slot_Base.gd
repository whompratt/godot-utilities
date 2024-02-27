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

# UI Elements
var itemUI: Control  # Reference to the Item scene

# Constructor
func _init(slot_type: SlotType = SlotType.INVENTORY):  
	slotType = slot_type

func _ready():
	set_process_input(true)
	
	# Load the Item scene as a child
	var itemScene = preload("res://GodotUI-Scripts-Library/Scripts/ITEM/item.tscn")
	itemUI = itemScene.instantiate() as Control
	add_child(itemUI)  # Add the Item scene instance as a child of this Slot
	itemUI.visible = false  # Initially hide the item UI

	# Update UI with item data
	update_item_ui()

func set_item(new_item: Item):
	item = new_item
	if itemUI:
		itemUI.queue_free()  # Remove existing item UI
	if item:
		var itemScene = preload("res://GodotUI-Scripts-Library/Scripts/ITEM/item.tscn")
		itemUI = itemScene.instantiate() as Control  # Create a new instance of the Item scene
		add_child(itemUI)  # Add the new item UI as a child
		itemUI.set_item(item)  # Set the item data
		itemUI.visible = true  # Show the item UI
	else:
		itemUI = null  # Set itemUI to null if no item, so it's properly handled
	update_item_ui()

func update_item_ui():
	if itemUI:
		itemUI.visible = true
	else:
		itemUI.visible = false

func _process(delta):
	if is_mouse_over():
		pass  # Implement hover effect if needed

func is_mouse_over() -> bool:
	var mouse_pos = get_global_mouse_position()
	return global_position.distance_to(mouse_pos) < size.x / 2  

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			_start_drag_and_drop()
		elif event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			pass  # Implement right-click behavior, like using or dropping items
		elif event.button_index == MOUSE_BUTTON_LEFT && !event.pressed:
			_stop_drag_and_drop()

func _start_drag_and_drop():
	if item and itemUI:
		var drag_data = {
			"item": item,
			"slot_type": slotType
		}
		var drag_preview = itemUI.create_drag_preview()
		get_tree().get_root().add_child(drag_preview)
		drag_preview.set_position(global_position)  
		drag_preview.start_drag(drag_data)

func _stop_drag_and_drop():
	if item and itemUI:
		get_tree().get_root().remove_child(itemUI.create_drag_preview())
		item = null
