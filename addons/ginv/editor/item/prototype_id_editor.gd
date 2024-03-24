@tool
extends Window

#region Constants
const POPUP_MARGIN = 10
#endregion

#region Public vars
var item: Item = null:
	set(new_item):
		if !new_item:
			return
		assert(!item)
		item = new_item
		if item.protoset:
			item.protoset.changed.connect(_refresh)
		_refresh()
#endregion

#region Onready vars
@onready var _margin_container: MarginContainer = $MarginContainer
@onready var _choice_filter: Control = $MarginContainer/ChoiceFilter
#endregion

#region Virtual functions
func _ready():
	about_to_popup.connect(func(): _refresh())
	close_requested.connect(func(): hide())
	_choice_filter.choice_picked.connect(func(index: int): _on_choice_picked(index))
	hide()
#endregion

#region Private functions
func _on_choice_picked(index: int):
	assert(item)
	var new_prototype_id = _choice_filter.values[index]
	if item.prototype_id != item.prototype_id:
		GInvUndoRedo.set_item_prototype_id(item, new_prototype_id)
	hide()

func _refresh():
	_choice_filter.values.clear()
	_choice_filter.values.append_array(_get_prototype_ids())
	_choice_filter.refresh()

func _get_prototype_ids() -> Array:
	if !item || !item.protoset:
		return []
	
	return item.protoset.prototypes.keys()
#endregion
