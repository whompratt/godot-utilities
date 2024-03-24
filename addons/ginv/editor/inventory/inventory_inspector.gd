@tool
extends Control

#region Public vars
var inventory: Inventory:
	set(new_inventory):
		inventory = new_inventory
		if inventory_editor:
			inventory_editor.inventory = inventory
#endregion

#region Onready functions
@onready var inventory_editor: Control = $HBoxContainer/InventoryEditor
@onready var button_expand: Button = $HBoxContainer/ButtonExpand
@onready var _window_dialogue: Window = $Window
@onready var _inventory_editor: Control = $Window/MarginContainer/InventoryEditor
#endregion

#region Virtual functions
func _ready():
	if inventory_editor:
		inventory_editor.inventory = inventory
	
	_apply_editor_settings()
	button_expand.pressed.connect(on_button_expand)
	_window_dialogue.close_requested.connect(func(): _window_dialogue.hide())

func _apply_editor_settings():
	var control_height: int = ProjectSettings.get_setting("ginv/inspector_control_height")
	custom_minimum_size.y = control_height
#endregion

#region Public functions
func init(_inventory: Inventory):
	inventory = _inventory

func on_button_expand():
	_inventory_editor.inventory = inventory
	_window_dialogue.popup_centered()
#endregion
