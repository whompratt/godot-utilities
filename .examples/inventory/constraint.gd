class_name Constraint extends Object

#region Public vars
var inventory: Inventory = null:
    set(new_inventory):
        assert(new_inventory, "Cannot set inventory to null")
        assert(!inventory, "Inventory already set")
        inventory = new_inventory
        _on_inventory_set()
#endregion

#region Virtual functions
func _init(new_inventory: Inventory):
    inventory = new_inventory

func _on_inventory_set():
    pass
#endregion

#region Public functions
func get_space_for(item: Item) -> int:
    return 0

func has_space_for(item: Item) -> bool:
    return false

func reset():
    pass
#endregion