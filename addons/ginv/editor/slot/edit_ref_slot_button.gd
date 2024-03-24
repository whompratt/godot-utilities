extends EditorProperty

#region Public vars
var updating: bool = false
#endregion

#region Private vars
var _option_button: OptionButton
#endregion

#region Virtual functions
func _init():
    _option_button = OptionButton.new()
    add_child(_option_button)
    add_focusable(_option_button)
    _option_button.item_selected.connect(_on_item_selected)

func _ready():
    var ref_slot: RefSlot = get_edited_object()
    ref_slot.inventory_changed.connect(_refresh_option_button)
    ref_slot.item_equipped.connect(_refresh_option_button)
    ref_slot.cleared.connect(_refresh_option_button)
    _refresh_option_button()
#endregion

#region Private functions
func _refresh_option_button():
    _clear_option_button()
    _populate_option_button()

func _clear_option_button():
    _option_button.clear()
    _option_button.add_item("None")
    _option_button.set_item_metadata(0, null)
    _option_button.select(0)

func _populate_option_button():
    if !get_edited_object():
        return
    
    var ref_slot: RefSlot = get_edited_object()
    if !ref_slot.inventory:
        return
    
    var equipped_item_index: int = 0
    for item in ref_slot.inventory.get_items():
        _option_button.add_icon_item(item.get_texture(), item.get_title())
        var option_index = _option_button.get_item_count() - 1
        _option_button.set_item_metadata(option_index, item)
        if item == ref_slot.get_item():
            equipped_item_index = option_index
    
    _option_button.select(equipped_item_index)

func _on_item_selected(index: int):
    if !get_edited_object() || updating:
        return

    updating = true
    var ref_slot: RefSlot = get_edited_object()
    var selected_item: Item = _option_button.get_item_metadata(index)
    if ref_slot.get_item() != selected_item:
        if !selected_item:
            GInvUndoRedo.clear_slot(ref_slot)
        else:
            GInvUndoRedo.equip_item_in_slot(ref_slot, selected_item)
    updating = false
#endregion