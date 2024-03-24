extends EditorInspectorPlugin

#region Constants
const EditProtosetButton = preload("res://addons/ginv/editor/protoset/edit_protoset_button.tscn")
const InventoryInspector = preload("res://addons/ginv/editor/inventory/inventory_inspector.tscn")
const SlotInspector = preload("res://addons/ginv/editor/slot/slot_inspector.tscn")
const EditRefSlotButton = preload("res://addons/ginv/editor/slot/edit_ref_slot_button.gd")
const EditPropertiesButton = preload("res://addons/ginv/editor/item/edit_properties_button.gd")
const EditPrototypeIdButton = preload("res://addons/ginv/editor/item/edit_prototype_id_button.gd")
#endregion

func _can_handle(object: Object) -> bool:
    return object is Inventory \
    || object is Item \
    || object is Slot \
    || object is RefSlot \
    || object is Protoset

func _parse_begin(object: Object):
    if object is Inventory:
        var inventory_inspector := InventoryInspector.instantiate()
        inventory_inspector.init(object as Inventory)
        add_custom_control(inventory_inspector)
    elif object is Slot:
        var slot_inspector := SlotInspector.instantiate()
        slot_inspector.init(object as Slot)
        add_custom_control(slot_inspector)
    elif object is Protoset:
        var protoset_inspector := EditProtosetButton.instantiate()
        protoset_inspector.init(object as Protoset)
        add_custom_control(protoset_inspector)
    else:
        print("No matched Node type, %s" % object)

func _parse_property(
    object,
    type,
    name,
    hint_type,
    hint_string,
    usage_flags,
    wide
) -> bool:
    if object is Item:
        match name:
            "properties":
                add_property_editor(name, EditPropertiesButton.new())
                return true
            "prototype_id":
                add_property_editor(name, EditPrototypeIdButton.new())
                return true
            _:
                return false
    elif object is RefSlot:
        match name:
            "_equipped_item":
                add_property_editor(name, EditRefSlotButton.new())
                return true
            _:
                return false
    else:
        return false