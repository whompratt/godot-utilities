@tool
class_name GInvUndoRedo extends Object

#region Public functions
static func add_item(inventory: Inventory, prototype_id: String):
    var undo_redo_manager = _get_undo_redo_manager()

    var old_inventory_state: Dictionary = inventory.serialise()
    if !inventory.create_and_add_item(prototype_id):
        return
    var new_inventory_state: Dictionary = inventory.serialise()

    undo_redo_manager.create_action("Add Item")
    undo_redo_manager.add_do_method(GInvUndoRedo, "_set_inventory", inventory, new_inventory_state)
    undo_redo_manager.add_undo_method(GInvUndoRedo, "_set_inventory", inventory, old_inventory_state)
    undo_redo_manager.commit_action()

static func remove_item(inventory: Inventory, item: Item):
    var undo_redo_manager = _get_undo_redo_manager()

    var old_inventory_state: Dictionary = inventory.serialise()
    if !inventory.remove_item(item):
        return
    var new_inventory_state: Dictionary = inventory.serialise()

    undo_redo_manager.create_action("Remove Item")
    undo_redo_manager.add_do_method(GInvUndoRedo, "_set_inventory", inventory, new_inventory_state)
    undo_redo_manager.add_undo_method(GInvUndoRedo, "_set_inventory", inventory, old_inventory_state)
    undo_redo_manager.commit_action()

static func remove_items(inventory: Inventory, items: Array[Item]):
    var undo_redo_manager = _get_undo_redo_manager()

    var old_inventory_state: Dictionary = inventory.serialise()
    for item in items:
        assert(inventory.remove_item(item))
    var new_inventory_state: Dictionary = inventory.serialise()

    undo_redo_manager.create_action("Remove Items")
    undo_redo_manager.add_do_method(GInvUndoRedo, "_set_inventory", inventory, new_inventory_state)
    undo_redo_manager.add_undo_method(GInvUndoRedo, "_set_inventory", inventory, old_inventory_state)
    undo_redo_manager.commit_action()

static func set_item_properties(item: Item, new_properties: Dictionary):
    var undo_redo_manager = _get_undo_redo_manager()

    var inventory: Inventory = item.get_inventory()

    if inventory:
        undo_redo_manager.create_action("Set Item Properties")
        undo_redo_manager.add_do_method(
            GInvUndoRedo,
            "_set_item_properties",
            inventory,
            inventory.get_item_index(item),
            new_properties
        )
        undo_redo_manager.add_undo_method(
            GInvUndoRedo,
            "_set_item_properties",
            inventory,
            inventory.get_item_index(item),
            item.properties
        )
    else:
        undo_redo_manager.create_action("Set Item Properties")
        undo_redo_manager.add_do_property(item, "properties", new_properties)
        undo_redo_manager.add_undo_property(item, "properties", item.properties)
        undo_redo_manager.commit_action()

static func set_item_prototype_id(item: Item, new_prototype_id: String):
    var undo_redo_manager = _get_undo_redo_manager()

    var inventory: Inventory = item.get_inventory()

    if inventory:
        undo_redo_manager.create_action("Set Prototype Id")
        undo_redo_manager.add_do_method(
            GInvUndoRedo,
            "_set_item_prototype_id",
            inventory,
            inventory.get_item_index(item),
            new_prototype_id
        )
        undo_redo_manager.add_undo_method(
            GInvUndoRedo,
            "_set_item_prototype_id",
            inventory,
            inventory.get_item_index(item),
            item.prototype_id
        )
        undo_redo_manager.commit_action()
    else:
        undo_redo_manager.create_action("Set Prototype Id")
        undo_redo_manager.add_do_property(
            item,
            "prototype_id",
            new_prototype_id
        )
        undo_redo_manager.add_undo_property(
            item,
            "prototype_id",
            item.prototype_id
        )
        undo_redo_manager.commit_action()

static func equip_item_in_slot(slot: SlotBase, item: Item):
    var undo_redo_manager = _get_undo_redo_manager()

    var old_slot_state: Dictionary = slot.serialise()
    if !slot.equip(item):
        return
    var new_slot_state: Dictionary = slot.serialise()

    undo_redo_manager.create_action("Equip Inventory Item")
    undo_redo_manager.add_do_method(GInvUndoRedo, "_set_slot", slot, new_slot_state)
    undo_redo_manager.add_undo_method(GInvUndoRedo, "_set_slot", slot, old_slot_state)
    undo_redo_manager.commit_action()

static func clear_slot(slot: SlotBase):
    var undo_redo_manager = _get_undo_redo_manager()

    var old_slot_state: Dictionary = slot.serialise()
    if !slot.clear():
        return
    var new_slot_state: Dictionary = slot.serialise()

    undo_redo_manager.create_action("Clear Item")
    undo_redo_manager.add_do_method(GInvUndoRedo, "_set_slot", slot, new_slot_state)
    undo_redo_manager.add_undo_method(GInvUndoRedo, "_set_slot", slot, old_slot_state)
    undo_redo_manager.commit_action()

static func move_item(inventory: InventoryGrid, item: Item, new_position: Vector2i):
    var undo_redo_manager = _get_undo_redo_manager()

    var old_position: Vector2i = inventory.get_item_position(item)
    if old_position == new_position:
        return
    var index: int = inventory.get_item_index(item)

    undo_redo_manager.create_action("Move Item")
    undo_redo_manager.add_do_method(GInvUndoRedo, "_move_item", inventory, index, new_position)
    undo_redo_manager.add_undo_method(GInvUndoRedo, "_move_item", inventory, index, old_position)
    undo_redo_manager.commit_action()

static func rotate_item(inventory: InventoryGrid, item: Item):
    var undo_redo_manager = _get_undo_redo_manager()

    if !inventory.can_rotate_item(item):
        return

    var old_rotation: bool = inventory.is_item_rotated(item)
    var index: int = inventory.get_item_index(item)

    undo_redo_manager.create_action("Rotate Item")
    undo_redo_manager.add_do_method(GInvUndoRedo, "_set_item_rotation", inventory, index, !old_rotation)
    undo_redo_manager.add_undo_method(GInvUndoRedo, "_set_item_rotation", inventory, index, old_rotation)
    undo_redo_manager.commit_action()

static func join_items(inventory: InventoryGridStack, item_source: Item, item_destination: Item):
    var undo_redo_manager = _get_undo_redo_manager()

    var old_inventory_state: Dictionary = inventory.serialise()
    if !inventory.join(item_source, item_destination):
        return
    var new_inventory_state: Dictionary = inventory.serialise()

    undo_redo_manager.create_action("Join Items")
    undo_redo_manager.add_do_method(GInvUndoRedo, "_set_inventory", inventory, new_inventory_state)
    undo_redo_manager.add_undo_method(GInvUndoRedo, "_set_inventory", inventory, old_inventory_state)
    undo_redo_manager.commit_action()

static func rename_prototype(protoset: Protoset, id: String, new_id: String):
    var undo_redo_manager = _get_undo_redo_manager()

    var old_prototypes = _prototypes_deep_copy(protoset)

    undo_redo_manager.create_action("Rename Prototype")
    undo_redo_manager.add_do_method(protoset, "rename_prototype", id, new_id)
    undo_redo_manager.add_undo_method(GInvUndoRedo, "_set_prototypes", protoset, old_prototypes)
    undo_redo_manager.commit_action()

static func add_prototype(protoset: Protoset, id: String):
    var undo_redo_manager = _get_undo_redo_manager()

    var old_prototypes = _prototypes_deep_copy(protoset)

    undo_redo_manager.create_action("Add Prototype")
    undo_redo_manager.add_do_method(protoset, "add_prototype", id)
    undo_redo_manager.add_undo_method(GInvUndoRedo, "_set_prototypes", protoset, old_prototypes)
    undo_redo_manager.commit_action()

static func remove_prototype(protoset: Protoset, id: String):
    var undo_redo_manager = _get_undo_redo_manager()

    var old_prototypes = _prototypes_deep_copy(protoset)

    undo_redo_manager.create_action("Remove Prototype")
    undo_redo_manager.add_do_method(protoset, "remove_prototype", id)
    undo_redo_manager.add_undo_method(GInvUndoRedo, "_set_prototypes", protoset, old_prototypes)
    undo_redo_manager.commit_action()

static func duplicate_prototype(protoset: Protoset, id: String):
    var undo_redo_manager = _get_undo_redo_manager()

    var old_prototypes = _prototypes_deep_copy(protoset)

    undo_redo_manager.create_action("Duplicate Prototype")
    undo_redo_manager.add_do_method(protoset, "duplicate_prototype", id)
    undo_redo_manager.add_undo_method(GInvUndoRedo, "_set_prototypes", protoset, old_prototypes)
    undo_redo_manager.commit_action()

static func set_prototype_properties(protoset: Protoset, prototype_id: String, new_properties: Dictionary):
    var undo_redo_manager = _get_undo_redo_manager()

    assert(protoset.has_prototype(prototype_id))
    var old_properties = protoset.get_prototype(prototype_id).duplicate()

    undo_redo_manager.create_action("Set Prototype Properties")
    undo_redo_manager.add_do_method(
        protoset,
        "set_prototype_properties",
        prototype_id,
        new_properties
    )
    undo_redo_manager.add_undo_method(
        protoset,
        "set_prototype_properties",
        prototype_id,
        old_properties
    )
    undo_redo_manager.commit_action()
#endregion

#region Private functions
static func _get_undo_redo_manager() -> EditorUndoRedoManager:
    var ginv = load("res://addons/ginv/ginv.gd")
    assert(ginv.instance())
    var undo_redo_manager = ginv.instance().get_undo_redo()
    assert(undo_redo_manager)
    return undo_redo_manager

static func _set_inventory(inventory: Inventory, data: Dictionary):
    inventory.deserialise(data)

static func _set_item_prototype_id(inventory: Inventory, index: int, new_prototype_id: String):
    assert(index < inventory.get_item_count())
    inventory.get_items()[index].prototype_id = new_prototype_id

static func _set_item_properties(inventory: Inventory, index: int, new_properties: Dictionary):
    assert(index < inventory.get_item_count())
    inventory.get_items()[index].properties = new_properties.duplicate()

static func _set_slot(slot: SlotBase, data: Dictionary):
    slot.deserialise(data)

static func _move_item(inventory: InventoryGrid, index: int, new_position: Vector2i):
    assert(index >= 0 && index < inventory.get_item_count())
    var item = inventory.get_items()[index]
    inventory.move_item_to(item, new_position)

static func _set_item_rotation(inventory: InventoryGrid, index: int, rotation: bool):
    assert(index >= 0 && index < inventory.get_item_count())
    var item = inventory.get_items()[index]
    inventory.set_item_rotation(item, rotation)

static func _prototypes_deep_copy(protoset: Protoset) -> Dictionary:
    var result = protoset.prototypes.duplicate()
    for prototype_id in result.keys():
        result[prototype_id] = protoset.prototypes[prototype_id].duplicate()
    return result

static func _set_prototypes(protoset: Protoset, prototypes: Dictionary):
    protoset.prototypes = prototypes
#endregion