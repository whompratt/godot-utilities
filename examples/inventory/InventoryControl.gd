class_name InventoryControl extends Control
## An instanceable Node for creating a new inventory

@export var inventory_name: String
@export var inventory_size: Vector2i = Vector2i(3, 2)
## The json file containing the saved contents of this inventory
@export var data_file: JSON

var grid_container: GridContainer
var inventory: Inventory

func _ready():
	## Ensure the data_file var has been set properly.
	##
	## If this script had the @tool annotation, then a custom configuration warning could be created
	## to alert if the path to a *.json file hadn't been set properly, turning this entire script into
	## a tool and having to add the extra overhead of handling `if Engine` everywhere just for a config
	## warning cannot be good practice.[br]
	## Instead, simply check that the var isn't empty by panicking if it is.
	assert(data_file, "data_file not set. Must be set to some .json resource.")

	# Initialise this inventory's Inventory
	inventory = Inventory.new(inventory_name, inventory_size)

	# Setup this inventory's GridContainer
	grid_container = GridContainer.new()
	grid_container.columns = inventory.size.x
	grid_container.set_anchors_preset(PRESET_FULL_RECT)
	grid_container.add_theme_constant_override("h_separation", 5)
	grid_container.add_theme_constant_override("v_separation", 5)
	self.add_child(grid_container)
	for i in range(inventory_size.x * inventory_size.y):
		var new_display = ColorRect.new()
		new_display.size = Vector2(10.0, 10.0)
		new_display.color = Color.RED
		new_display.size_flags_horizontal = SIZE_EXPAND_FILL
		new_display.size_flags_vertical = SIZE_EXPAND_FILL
		grid_container.add_child(new_display)

func save_contents():
	data_file.data = JSON.stringify([
		{
			"name": "1"
		},
		{
			"name": "2"
		},
		{

		},
		{
			"name": "4"
		}
	])