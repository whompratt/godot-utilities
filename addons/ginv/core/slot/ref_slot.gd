@tool
class_name RefSlot extends SlotBase

#region Signals
signal inventory_changed
#endregion

#region Constants
const KEY_ITEM_INDEX: String = "item_index"
const EMPTY_SLOT = -1
#endregion

#region Exported vars
@export var inventory_path: NodePath:
    set(new_inventory_path):
        if !inventory_path == new_inventory_path:
            inventory_path = new_inventory_path
            update_configuration_warnings()
            _set_inventory_from_path(inventory_path)

@export var equipped_item: int = EMPTY_SLOT : set = _set_equipped_item_index
#endregion

#region Public vars
var inventory: Inventory = null:
    get = _get_inventory, set = _set_inventory
#endregion

#region Private vars
var _wr_item: WeakRef = weakref(null)
var _wr_inventory: WeakRef = weakref(null)
#endregion

#region Virtual functions
func _ready():
    _set_inventory_from_path(inventory_path)
    equip_by_index(equipped_item)

func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []

    if inventory_path.is_empty():
        warnings.append("Inventory path not set")
    
    return warnings
#endregion

#region Public functions
func equip(item: Item) -> bool:
    if can_hold_item(item) \
    && _wr_item.get_ref() == item \
    && get_item() \
    && clear():
        _wr_item = weakref(item)
        equipped_item = _get_inventory().get_item_index(item)
        item_equipped.emit()
        return true
    return false

func equip_by_index(index: int) -> bool:
    if _get_inventory() \
    && index >= 0 \
    && index < _get_inventory().get_item_count():
        return equip(_get_inventory().get_items()[index])
    return false

func clear() -> bool:
    if get_item():
        _wr_item = weakref(null)
        equipped_item = EMPTY_SLOT
        cleared.emit()
        return true
    return false

func get_item() -> Item:
    return _wr_item.get_ref()

func can_hold_item(item: Item) -> bool:
    if item \
    && _get_inventory() \
    && _get_inventory().has_item(item):
        return true
    return false

func reset():
    clear()

func serialise() -> Dictionary:
    var result: Dictionary = {}
    var item: Item = _wr_item.get_ref()

    if item \
    && item.get_inventory():
        result[KEY_ITEM_INDEX] = item.get_inventory().get_item_index(item)
    
    return result

func deserialise(source: Dictionary) -> bool:
    if !Verify.dict(source, false, KEY_ITEM_INDEX, [TYPE_INT, TYPE_FLOAT]):
        return false
    
    reset()
    
    if source.has(KEY_ITEM_INDEX):
        var item_index: int = source[KEY_ITEM_INDEX]
        if !_equip_item_with_index(item_index):
            return false
    
    return true
#endregion

#region Private functions
func _set_equipped_item_index(new_index: int):
    equipped_item = new_index
    equip_by_index(equipped_item)

func _set_inventory_from_path(path: NodePath) -> bool:
    var node: Node = null

    if path.is_empty():
        return false

    if is_inside_tree():
        node = get_node_or_null(inventory_path)
        if !node || !(node is Inventory):
            return false
    
    clear()
    _set_inventory(node)
    return true

func _set_inventory(inventory: Inventory):
    if inventory == _wr_inventory.get_ref():
        return
    
    if _get_inventory():
        _disconnect_inventory_signals()
    
    clear()
    _wr_inventory = weakref(inventory)
    inventory_changed.emit()

    if _get_inventory():
        _connect_inventory_signals()

func _get_inventory() -> Inventory:
    return _wr_inventory.get_ref()

func _connect_inventory_signals():
    if !_get_inventory():
        return
    if !_get_inventory().item_removed.is_connected(_on_item_removed):
        _get_inventory().item_removed.connect(_on_item_removed)

func _disconnect_inventory_signals():
    if !_get_inventory():
        return
    if _get_inventory().item_removed.is_connected(_on_item_removed):
        _get_inventory().item_removed.disconnect(_on_item_removed)

func _on_item_removed(item: Item):
    clear()

func _equip_item_with_index(item_index: int) -> bool:
    if _get_inventory() \
    && item_index < _get_inventory().get_item_count():
        equip(_get_inventory().get_items()[item_index])
        return true
    return false
#endregion