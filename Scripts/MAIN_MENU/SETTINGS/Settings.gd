extends MarginContainer

func _ready():
	# Connect the button signals
	$VBoxContainer/Keybindings.connect("pressed", Callable(self, "_on_keybindings_pressed"))
	$VBoxContainer/AudioSettings.connect("pressed", Callable(self, "_on_audio_settings_pressed"))
	$VBoxContainer/RenderingSettings.connect("pressed", Callable(self, "_on_rendering_settings_pressed"))
	$VBoxContainer/Back.connect("pressed", Callable(self, "_on_back_pressed"))

func _on_keybindings_pressed():
	# Implement keybindings logic here
	print("Keybindings")

func _on_audio_settings_pressed():
	# Implement audio settings logic here
	print("Audio Settings")

func _on_rendering_settings_pressed():
	# Implement rendering settings logic here
	print("Rendering Settings")

func _on_back_pressed():
	# Switch back to Main Menu
	var main_menu = "res://GodotUI-Scripts-Library/Scripts/MAIN_MENU/MainMenu.tscn"
	get_tree().change_scene_to_file(main_menu)
