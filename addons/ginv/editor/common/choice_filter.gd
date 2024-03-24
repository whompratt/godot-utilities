@tool
extends Control

#region Signals
signal choice_picked(index)
signal choice_selected(index)
#endregion

#region Exported vars
@export var pick_button_visible: bool = true:
	set(new_pick_button_visible):
		pick_button_visible = new_pick_button_visible
		if button_pick:
			button_pick.visible = pick_button_visible
@export var pick_text: String:
	set(new_pick_text):
		pick_text = new_pick_text
		if button_pick:
			button_pick.text = pick_text
@export var filter_text: String = "Filter:":
	set(new_filter_text):
		filter_text = new_filter_text
		if label_filter:
			label_filter.text = filter_text
@export var values: Array[String]
#endregion

#region Onready vars
@onready var label_filter: Label = $HBoxContainer/Label
@onready var line_edit: LineEdit = $HBoxContainer/LineEdit
@onready var item_list: ItemList = $ItemList
@onready var button_pick: Button = $Button
#endregion

#region Virtual functions
func _ready():
	button_pick.pressed.connect(_on_button_pick)
	line_edit.text_changed.connect(_on_filter_text_changed)
	item_list.item_activated.connect(_on_item_activated)
	item_list.item_selected.connect(_on_item_selected)
	refresh()

	if button_pick:
		button_pick.text = pick_text
		button_pick.visible = pick_button_visible
	if label_filter:
		label_filter.text = filter_text
#endregion

#region Public functions
func refresh():
	_clear()
	_populate()

func get_selected_item() -> int:
	var selected: PackedInt32Array = item_list.get_selected_items()
	if selected.size() > 0:
		return item_list.get_item_metadata(selected[0])
	else:
		return -1

func get_selected_text() -> String:
	var selected: int = get_selected_item()
	if selected >= 0:
		return values[selected]
	else:
		return ""

func set_values(new_values: Array):
	values.clear()
	for new_value in new_values:
		if new_value is String:
			values.push_back(new_value)
	
	refresh()
#endregion

#region Private functions
func _clear():
	if item_list:
		item_list.clear()

func _populate():
	if !line_edit || !item_list || !values || values.size() == 0:
		return
	
	if !values || values.size() == 0:
		return
	
	for index in range(values.size()):
		var value = values[index]
		if !line_edit.text.is_empty() && !line_edit.text.to_lower() in value.to_lower():
			continue
		item_list.add_item(value)
		item_list.set_item_metadata(item_list.get_item_count() - 1, index)

func _on_button_pick():
	var selected_items: PackedInt32Array = item_list.get_selected_items()
	if selected_items.is_empty():
		return
	
	var selected_item = selected_items[0]
	var selected_index = item_list.get_item_metadata(selected_item)
	choice_picked.emit(selected_index)

func _on_filter_text_changed(_new_text: String):
	refresh()

func _on_item_activated(index: int):
	var selected_index = item_list.get_item_metadata(index)
	choice_picked.emit(selected_index)

func _on_item_selected(index: int):
	var selected_index = item_list.get_item_metadata(index)
	choice_selected.emit(selected_index)
#endregion
