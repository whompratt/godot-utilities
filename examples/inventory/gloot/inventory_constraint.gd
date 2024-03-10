extends Object

var inventory: GlootInventory = null :
	set(new_inventory):
		assert(new_inventory != null, "Can't set inventory to null!")
		assert(inventory == null, "InventGlootInventorydy set!")
		inventory = new_inventory
		_on_inventory_set()


func _init(inventory_: GlootInventory) -> void:
	inventory = inventory_


# Override this
func get_space_for(item: GlootInventoryItem) -> GlootItemCount:
	return GlootItemCount.zero()


# Override this
func has_space_for(item:GlootInventoryItem) -> bool:
	return false


# Override this
func reset() -> void:
	pass


# Override this
func serialize() -> Dictionary:
	return {}


# Override this
func deserialize(source: Dictionary) -> bool:
	return true
	
	
# Override this
func _on_inventory_set() -> void:
	pass


# Override this
func _on_item_added(item: GlootInventoryItem) -> void:
	pass


# Override this
func _on_item_removed(item: GlootInventoryItem) -> void:
	pass

	
# Override this
func _on_item_modified(item: GlootInventoryItem) -> void:
	pass
