extends Control

func _ready():
	add_child(KeyManager)
	createUI()

func createUI():
	var vbox_container = VBoxContainer.new()
	vbox_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(vbox_container)

	for action_name in KeyManager.DEFAULT_KEY_MAP.keys():
		var hbox = HBoxContainer.new()
		vbox_container.add_child(hbox)

		var label = Label.new()
		label.text = action_name.capitalize() + ":"
		hbox.add_child(label)


##errors here - this parts signal is not working
		var button = KeyBindingButton.new()
		button.action = action_name
		button.text = "..."
		button.size = Vector2(120, 30)
		button.connect("toggled", Callable(self, "_on_button_toggled"))
		hbox.add_child(button)

	var saveButton = Button.new()
	saveButton.text = "Save"
	saveButton.size = Vector2(200, 30)
	saveButton.connect("pressed", Callable(self, "_on_save_pressed"))
	vbox_container.add_child(saveButton)

	var backButton = Button.new()
	backButton.text = "Back"
	backButton.size = Vector2(200, 30)
	backButton.connect("pressed", Callable(self, "_on_back_pressed"))
	vbox_container.add_child(backButton)

	var testButton = Button.new()
	testButton.text = "Test Keybinds"
	testButton.size = Vector2(200, 30)
	testButton.connect("pressed", Callable(self, "_on_test_pressed"))
	vbox_container.add_child(testButton)

func _on_button_toggled(action_name: String, is_button_pressed: bool):
	print("click")
	if is_button_pressed:
		print("Button toggled:", action_name)

func _on_save_pressed():
	# Save the keybindings
	KeyManager.save_keymap()
	print("Keybindings saved.")

func _on_back_pressed():
	# Logic to go back or close the keybinding menu
	# For demonstration, print a message
	print("Back button pressed.")

func _on_test_pressed():
	# Test button to output contents of the keybind file
	var keymaps = KeyManager.keymaps
	print("Current Key Bindings:")
	for action in keymaps:
		print(action + ":")
