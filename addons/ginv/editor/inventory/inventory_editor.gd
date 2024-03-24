@tool
extends Control

#region Public vars
var inventory: Inventory:
	set(new_inventory):
		disconnect_inventory_signals()
		inventory = new_inventory
		connect_inventory_signals()

		_refresh()
#endregion

#region Private vars
var _inventory_control: Control
#endregion

#region Onready vars
@onready var hsplit_container = $HSplitContainer
@onready var prototype_id_filter = $HSplitContainer/ChoiceFilter
@onready var inventory_control_container = $HSplitContainer/VBoxContainer
@onready var button_edit = $HSplitContainer/VBoxContainer/HBoxContainer/ButtonEdit
@onready var button_remove = $HSplitContainer/VBoxContainer/HBoxContainer/ButtonRemove
@onready var scroll_container = $HSplitContainer/VBoxContainer/ScrollContainer
#endregion

#region Virtual functions
func _ready():
	prototype_id_filter.choice_picked.connect(_on_prototype_id_picked)
	button_edit.pressed.connect(_on_button_edit)
	button_remove.pressed.connect(_on_button_remove)
#endregion

#region Public functions
func connect_inventory_signals():
	if !inventory:
		return
	
	if inventory is InventoryStack:
		inventory.capacity_changed.connect(_refresh)
	if inventory is InventoryGrid:
		inventory.size_changed.connect(_refresh)

	inventory.protoset_changed.connect(_refresh)

	if !inventory.protoset:
		return
	
	inventory.protoset.changed.connect(_refresh)

func disconnect_inventory_signals():
	if !inventory:
		return
	
	if inventory is InventoryStack:
		inventory.capacity_changed.disconnect(_refresh)
	if inventory is InventoryGrid:
		inventory.size_changed.disconnect(_refresh)
	
	inventory.protoset_changed.disconnect(_refresh)

	if !inventory.protoset:
		return
	
	inventory.protoset.changed.disconnect(_refresh)
#endregion

#region Private functions
func _refresh():
	if !is_inside_tree() || !inventory || !inventory.protoset:
		return
	
	if _inventory_control:
		scroll_container.remove_child(_inventory_control)
		_inventory_control.queue_free()
		_inventory_control = null
	
	if inventory is InventoryGrid:
		_inventory_control = ControlInventoryGrid.new()
		_inventory_control.grid_color = Color.GRAY
		_inventory_control.draw_selections = true
	elif inventory is InventoryStack:
		_inventory_control = ControlInventoryStack.new()
	elif inventory is Inventory:
		_inventory_control = ControlInventory.new()
	
	_inventory_control.size_flags_horizontal = SIZE_EXPAND_FILL
	_inventory_control.size_flags_vertical = SIZE_EXPAND_FILL
	_inventory_control.inventory = inventory
	_inventory_control.item_activated.connect(_on_item_activated)
	_inventory_control.item_context_activated.connect(_on_item_context_activated)

	scroll_container.add_child(_inventory_control)
	prototype_id_filter.set_values(inventory.protoset.prototypes.keys())

func _on_item_activated(item: Item):
	GInvUndoRedo.remove_item(inventory, item)

func _on_item_context_activated(item: Item):
	GInvUndoRedo.rotate_item(inventory, item)

func _on_prototype_id_picked(index: int):
	var prototype_id = prototype_id_filter.values[index]
	GInvUndoRedo.add_item(inventory, prototype_id)

func _on_button_edit():
	var selected_item: Item = _inventory_control.get_selected_item()
	if selected_item:
		call_deferred("_selected_node", selected_item)

func _on_button_remove():
	var selected_item: Item = _inventory_control.get_selected_item()
	if selected_item:
		GInvUndoRedo.remove_item(inventory, selected_item)

static func _select_node(node: Node):
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(node)
	EditorInterface.edit_node(node)
#endregion
