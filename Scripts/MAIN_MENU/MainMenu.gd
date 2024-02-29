extends MarginContainer

func _ready():
	# Connect the button signals
	$VBoxContainer/NewGame.connect("pressed", Callable(self, "_on_new_game_pressed"))
	$VBoxContainer/LoadGame.connect("pressed", Callable(self, "_on_load_game_pressed"))
	$VBoxContainer/Settings.connect("pressed", Callable(self, "_on_settings_pressed"))
	$VBoxContainer/Exit.connect("pressed", Callable(self, "_on_exit_pressed"))

func _on_new_game_pressed():
	# Implement New Game logic here
	print("New Game")

func _on_load_game_pressed():
	# Implement Load Game logic here
	print("Load Game")

func _on_settings_pressed():
	# Switch to Settings scene
	var settings_scene = "res://GodotUI-Scripts-Library/Scripts/MAIN_MENU/SETTINGS/Settings.tscn"
	get_tree().change_scene_to_file(settings_scene)

func _on_exit_pressed():
	# Exit the game
	get_tree().quit()
