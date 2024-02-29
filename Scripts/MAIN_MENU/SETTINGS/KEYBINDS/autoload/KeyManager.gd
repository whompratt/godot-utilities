extends Node

const DEFAULT_KEY_MAP = {
	"move_up": [KEY_W],
	"move_left": [KEY_A],
	"move_down": [KEY_S],
	"move_right": [KEY_D],
	"open_inventory": [KEY_E],
	"open_menu": [KEY_I],
}
const keymaps_path = "user://keymaps.dat"

var keymaps: Dictionary

func _ready():
	keymaps = {}
	for action in InputMap.get_actions():
		if InputMap.action_get_events(action).size() != 0:
			keymaps[action] = InputMap.action_get_events(action)
	load_keymap()

func load_keymap():
	if FileAccess.file_exists(keymaps_path):
		var file = FileAccess.open(keymaps_path, FileAccess.READ)
		file.open(keymaps_path, FileAccess.READ)
		var temp_keymap = file.get_var() as Dictionary
		file.close()
		for action in keymaps.keys():
			if temp_keymap.has(action):
				keymaps[action] = temp_keymap[action]
				InputMap.action_erase_events(action)
				for event in keymaps[action]:
					InputMap.action_add_event(action, event)	
	else:
#		var file = FileAccess.open(keymaps_path, FileAccess.READ)
#		file.open(keymaps_path, FileAccess.WRITE)
#		file.store_var(DEFAULT_KEY_MAP)
#		file.close()
#		return
		pass


func save_keymap():
	var file = FileAccess.open(keymaps_path, FileAccess.WRITE)
	file.open(keymaps_path, FileAccess.WRITE)
	file.store_var(keymaps)
	file.close()

func reset_keymap():
	for action in DEFAULT_KEY_MAP:
		InputMap.action_erase_events(action)
		var events = []
		for key in DEFAULT_KEY_MAP[action]:
			var event
			if key == MOUSE_BUTTON_LEFT or key == MOUSE_BUTTON_MIDDLE or key == MOUSE_BUTTON_RIGHT:
				event = InputEventMouseButton.new()
				event.set_button_index(key)
			else:
				event = InputEventKey.new()
				event.set_keycode(key)
			if event:
				events.append(event)
				InputMap.action_add_event(action, event)
		keymaps[action] = events
	save_keymap()
