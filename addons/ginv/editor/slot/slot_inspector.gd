@tool
extends Control

#region Onready vars
@onready var slot_editor: Control = $HBoxContainer/SlotEditor
@onready var button_expand: Button = $HBoxContainer/ButtonExpand
@onready var _window_dialogue: Window = $Window
@onready var _slot_editor: Control = $Window/MarginContainer/SlotEditor
#endregion

#region Public vars
var slot: Slot:
	set(new_slot):
		slot = new_slot
		if slot_editor:
			slot_editor.slot = slot
#endregion

#region Virtual functions
func _ready():
	if slot_editor:
		slot_editor.slot = slot
	_apply_editor_settings()
	button_expand.pressed.connect(on_button_expand)
	_window_dialogue.close_requested.connect(func(): _window_dialogue.hide())
#endregion

#region Public functions
func init(_slot: Slot):
	slot = _slot

func on_button_expand():
	_slot_editor.slot = slot
	_window_dialogue.popup_centered()
#endregion

#region Private functions
func _apply_editor_settings():
	var control_height: int = ProjectSettings.get_setting("ginv/inspector_control_height")
	custom_minimum_size.y = control_height
#endregion
