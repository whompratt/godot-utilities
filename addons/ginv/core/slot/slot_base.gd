@tool
class_name SlotBase extends Node

#region Signals
signal item_equipped
signal cleared
#endregion

#region Override functions
func equip(item: Item) -> bool:
    return false

func clear() -> bool:
    return false

func get_item() -> Item:
    return null

func can_hold_item(item: Item) -> bool:
    return false

func reset():
    pass

func serialise() -> Dictionary:
    return {}

func deserialise(source: Dictionary) -> bool:
    return false
#endregion