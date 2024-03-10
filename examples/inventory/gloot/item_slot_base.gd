@tool
class_name GlootItemSlotBase
extends Node

signal item_equipped
signal cleared


# Override this
func equip(item: GlootInventoryItem) -> bool:
    return false


# Override this
func clear() -> bool:
    return false


# Override this
func get_item() -> GlootInventoryItem:
    return null


# Override this
func can_hold_item(item: GlootInventoryItem) -> bool:
    return false


# Override this
func reset() -> void:
    pass


# Override this
func serialize() -> Dictionary:
    return {}


# Override this
func deserialize(source: Dictionary) -> bool:
    return false