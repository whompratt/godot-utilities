@tool
extends Control

#region Onready vars
@onready var hsplit_container = $HSplitContainer
@onready var prototype_id_filter = $HSplitContainer/ChoiceFilter
@onready var button_edit = $HSplitContainer/VBoxContainer/HBoxContainer/ButtonEdit
@onready var button_clear = $HSplitContainer/VBoxContainer/HBoxContainer/ButtonClear
@onready var control_slot = $HSplitContainer/VBoxContainer/ControlSlot
#endregion

#region Public vars
var slot: Slot:
	set(new_slot):
		disconnect_slot_signals()
		slot = new_slot
		control_slot.slot = slot
		connect_slot_signals()
		_refresh()
#endregion

#region Virtual functions
func _ready():
	_apply_editor_settings()

	prototype_id_filter.choice_picked.connect(_on_prototype_id_picked)
	button_edit.pressed.connect(_on_button_edit)
	button_clear.pressed.connect(_on_button_clear)

	control_slot.slot = slot
	_refresh()
#endregion

#region Public functions
func init(_slot: Slot):
	slot = _slot

func connect_slot_signals():
	if !slot:
		return

	slot.item_equipped.connect(_refresh)
	slot.cleared.connect(_refresh)

	if !slot.protoset:
		return
	
	slot.protoset.changed.connect(_refresh)
	slot.protoset_changed.connect(_refresh)

func disconnect_slot_signals():
	if !slot:
		return
	
	slot.item_equipped.disconnect(_refresh)
	slot.cleared.disconnect(_refresh)

	if !slot.protoset:
		return
	
	slot.protoset.changed.disconnect(_refresh)
	slot.protoset_changed.disconnect(_refresh)
#endregion

#region Private functions
func _refresh():
	if !is_inside_tree() || !slot || !slot.protoset:
		return
	prototype_id_filter.set_values(slot.protoset._prototypes.keys())

func _apply_editor_settings():
	var control_height: int = ProjectSettings.get_setting("ginv/inspector_control_height")

func _on_prototype_id_picked(index: int):
	var prototype_id = prototype_id_filter.values[index]
	var item: Item = Item.new()
	if slot.get_item():
		slot.get_item().queue_free()
	item.protoset = slot.protoset
	item.prototype_id = prototype_id
	GInvUndoRedo.equip_item_in_slot(slot, item)

func _on_button_edit():
	if slot.get_item():
		call_deferred("_selected_node", slot.get_item())

func _on_button_clear():
	if slot.get_item():
		slot.get_item().queue_free()
		GInvUndoRedo.clear_slot(slot)

static func _select_node(node: Node):
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(node)
	EditorInterface.edit_node(node)
#endregion
