extends Button

class_name KeyBindingButton

@export var action: String = "move_left"
@export var primary: bool = true

var remap_mode = false

func _ready():
	display_current_key()

func display_current_key():
	var action_events = InputMap.action_get_events(action)
	var current_key = ""
	if action_events.size() == 0:
		current_key = "."
	elif primary:
		current_key = action_events[0].as_text()
	elif action_events.size() > 1:
		current_key = action_events[1].as_text()
	
	if remap_mode:
		current_key = "..."
		
	text = current_key

func remap_action_to(event):
	var action_events = InputMap.action_get_events(action)
	InputMap.action_erase_events(action)
	var events = []
	if primary:
		events.append(event)
		if action_events.size() > 1:
			events.append(action_events[1])
	else:
		events.append(action_events[0])
		events.append(event)
	for e in events:
		InputMap.action_add_event(action, e)
	KeyManager.keymaps[action] = events
	KeyManager.save_keymap()
	remap_mode = false  # Exit remap mode
	display_current_key()  # Update button text after remapping

func _on_toggled(is_button_pressed):
	remap_mode = is_button_pressed
	if is_button_pressed:
		text = "..."  # Show "..." when in remap mode
		release_focus()
	else:
		display_current_key()  # Update button text when remap mode is exited

func _input(event):
	if remap_mode:
		if event is InputEventKey or event is InputEventMouseButton:
			remap_action_to(event)
			if event is InputEventKey or not event.button_index == MOUSE_BUTTON_LEFT:
				button_pressed = false
