@tool
class_name ControlSlot extends Control

#region Exported vars
@export var slot_path: NodePath:
	set(new_slot_path):
		if slot_path == new_slot_path:
			return
		slot_path = new_slot_path
		var node: Node = get_node_or_null(slot_path)
		
		if !node:
			_clear()
			return

		if is_inside_tree():
			assert(node is SlotBase)
			
		slot = node
		_refresh()
		update_configuration_warnings()

@export var default_item_icon: Texture2D:
	set(new_default_item_icon):
		if default_item_icon == new_default_item_icon:
			return
		default_item_icon = new_default_item_icon
		_refresh()

@export var item_texture_visible: bool = true:
	set(new_item_texture_visible):
		if item_texture_visible == new_item_texture_visible:
			return
		item_texture_visible = new_item_texture_visible
		if is_instance_valid(_control_item_rect):
			_control_item_rect.visible = item_texture_visible

@export var label_visible: bool = true:
	set(new_label_visible):
		if label_visible == new_label_visible:
			return
		label_visible = new_label_visible
		if is_instance_valid(_label):
			_label.visible = label_visible


@export_group("Icon Behavior", "icon_")
@export var icon_stretch_mode: TextureRect.StretchMode = TextureRect.StretchMode.STRETCH_KEEP_CENTERED:
	set(new_icon_stretch_mode):
		if icon_stretch_mode == new_icon_stretch_mode:
			return
		icon_stretch_mode = new_icon_stretch_mode
		if is_instance_valid(_control_item_rect):
			_control_item_rect.stretch_mode = icon_stretch_mode


@export_group("Text Behavior", "label_")
@export var label_horizontal_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER:
	set(new_label_horizontal_alignment):
		if label_horizontal_alignment == new_label_horizontal_alignment:
			return
		label_horizontal_alignment = new_label_horizontal_alignment
		if is_instance_valid(_label):
			_label.horizontal_alignment = label_horizontal_alignment

@export var label_vertical_alignment: VerticalAlignment = VERTICAL_ALIGNMENT_CENTER:
	set(new_label_vertical_alignment):
		if label_vertical_alignment == new_label_vertical_alignment:
			return
		label_vertical_alignment = new_label_vertical_alignment
		if is_instance_valid(_label):
			_label.vertical_alignment = label_vertical_alignment
			
@export var label_text_overrun_behavior: TextServer.OverrunBehavior:
	set(new_label_text_overrun_behavior):
		if label_text_overrun_behavior == new_label_text_overrun_behavior:
			return
		label_text_overrun_behavior = new_label_text_overrun_behavior
		if is_instance_valid(_label):
			_label.text_overrun_behavior = label_text_overrun_behavior
			
@export var label_clip_text: bool:
	set(new_label_clip_text):
		if label_clip_text == new_label_clip_text:
			return
		label_clip_text = new_label_clip_text
		if is_instance_valid(_label):
			_label.clip_text = label_clip_text
#endregion

#region Public vars
var slot: SlotBase :
	set(new_slot):
		if new_slot == slot:
			return

		_disconnect_item_slot_signals()
		slot = new_slot
		_connect_item_slot_signals()
		
		_refresh()
#endregion

#region Private vars
var _hbox_container: HBoxContainer
var _control_item_rect: ControlItemRect
var _label: Label
var _control_drop_zone: ControlDropZone
#endregion

#region Virtual functions
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if slot_path.is_empty():
		warnings.append("Node not linked to slot, set slot_path to a SlotBase node")

	return warnings

func _ready():
	if Engine.is_editor_hint():
		if is_instance_valid(_hbox_container):
			_hbox_container.queue_free()

	var node: Node = get_node_or_null(slot_path)

	if is_inside_tree() && node:
		assert(node is SlotBase)

	slot = node
	
	_hbox_container = HBoxContainer.new()
	_hbox_container.size_flags_horizontal = SIZE_EXPAND_FILL
	_hbox_container.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(_hbox_container)
	_hbox_container.resized.connect(func(): size = _hbox_container.size)

	_control_item_rect = ControlItemRect.new()
	_control_item_rect.visible = item_texture_visible
	_control_item_rect.size_flags_horizontal = SIZE_EXPAND_FILL
	_control_item_rect.size_flags_vertical = SIZE_EXPAND_FILL
	_control_item_rect.slot = slot
	_control_item_rect.stretch_mode = icon_stretch_mode
	_hbox_container.add_child(_control_item_rect)

	_control_drop_zone = ControlDropZone.new()
	_control_drop_zone.draggable_dropped.connect(_on_draggable_dropped)
	_control_drop_zone.size = size
	resized.connect(func(): _control_drop_zone.size = size)
	ControlDraggable.draggable_grabbed.connect(_on_any_draggable_grabbed)
	ControlDraggable.draggable_dropped.connect(_on_any_draggable_dropped)
	add_child(_control_drop_zone)
	_control_drop_zone.deactivate()

	_label = Label.new()
	_label.visible = label_visible
	_label.size_flags_horizontal = SIZE_EXPAND_FILL
	_label.size_flags_vertical = SIZE_EXPAND_FILL
	_label.horizontal_alignment = label_horizontal_alignment
	_label.vertical_alignment = label_vertical_alignment
	_label.text_overrun_behavior = label_text_overrun_behavior
	_label.clip_text = label_clip_text
	_hbox_container.add_child(_label)

	_hbox_container.size = size
	resized.connect(func():
		_hbox_container.size = size
	)

	_refresh()
#endregion

#region Private functions
func _connect_item_slot_signals():
	if !is_instance_valid(slot):
		return

	if !slot.item_equipped.is_connected(_refresh):
		slot.item_equipped.connect(_refresh)
	if !slot.cleared.is_connected(_refresh):
		slot.cleared.connect(_refresh)

func _disconnect_item_slot_signals():
	if !is_instance_valid(slot):
		return

	if slot.item_equipped.is_connected(_refresh):
		slot.item_equipped.disconnect(_refresh)
	if slot.cleared.is_connected(_refresh):
		slot.cleared.disconnect(_refresh)

func _on_draggable_dropped(draggable: ControlDraggable, drop_position: Vector2):
	var item = (draggable as ControlItemRect).item

	if !item:
		return
	if !is_instance_valid(slot):
		return
	if !slot.can_hold_item(item):
		return
	if item == slot.get_item():
		return

	slot.equip(item)

func _on_any_draggable_grabbed(draggable: ControlDraggable, grab_position: Vector2):
	_control_drop_zone.activate()

func _on_any_draggable_dropped(draggable: ControlDraggable, zone: ControlDropZone, drop_position: Vector2):
	_control_drop_zone.deactivate()

func _refresh():
	_clear()

	if !is_instance_valid(slot):
		return
	if slot.get_item() == null:
		return

	var item = slot.get_item()
	
	if is_instance_valid(_label):
		_label.text = item.get_property(ControlInventory.KEY_NAME, item.prototype_id)
	if is_instance_valid(_control_item_rect):
		_control_item_rect.item = item
		if item.get_texture():
			_control_item_rect.texture = item.get_texture()

func _clear():
	if is_instance_valid(_label):
		_label.text = ""
	if is_instance_valid(_control_item_rect):
		_control_item_rect.item = null
		_control_item_rect.texture = default_item_icon
#endregion
