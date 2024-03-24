@tool
class_name ControlInventory extends Control

#region Signals
signal item_activated(item)
signal item_context_activated(item)
#endregion

#region Constants
const KEY_IMAGE = "image"
const KEY_NAME = "name"
#endregion

#region Exported vars
@export var inventory_path: NodePath:
    set(new_inventory_path):
        inventory_path = new_inventory_path
        var node: Node = get_node_or_null(inventory_path)

        if node == null:
            return

        if is_inside_tree():
            assert(node is Inventory)
            
        inventory = node
        update_configuration_warnings()

@export var default_item_icon: Texture2D
var inventory: Inventory = null :
    set(new_inventory):
        if new_inventory == inventory:
            return

        _disconnect_inventory_signals()
        inventory = new_inventory
        _connect_inventory_signals()
        _queue_refresh()
#endregion

#region Private vars
var _vbox_container: VBoxContainer
var _item_list: ItemList
var _refresh_queued: bool = false
#endregion

#region Virtual functions
func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []

    if inventory_path.is_empty():
        warnings.append("Node not linked to inventory, set inventory_path")

    return warnings

func _ready():
    if Engine.is_editor_hint():
        if is_instance_valid(_vbox_container):
            _vbox_container.queue_free()

    _vbox_container = VBoxContainer.new()
    _vbox_container.size_flags_horizontal = SIZE_EXPAND_FILL
    _vbox_container.size_flags_vertical = SIZE_EXPAND_FILL
    _vbox_container.anchor_right = 1.0
    _vbox_container.anchor_bottom = 1.0
    add_child(_vbox_container)

    _item_list = ItemList.new()
    _item_list.size_flags_horizontal = SIZE_EXPAND_FILL
    _item_list.size_flags_vertical = SIZE_EXPAND_FILL
    _item_list.item_activated.connect(_on_list_item_activated)
    _item_list.item_clicked.connect(_on_list_item_clicked)
    _vbox_container.add_child(_item_list)

    if has_node(inventory_path):
        inventory = get_node(inventory_path)

    _queue_refresh()

func _process(_delta):
    if _refresh_queued:
        _refresh()
        _refresh_queued = false
#endregion

#region Public functions
func get_selected_item() -> Item:
    if _item_list.get_selected_items().is_empty():
        return null

    return _get_item(_item_list.get_selected_items()[0])

func select_item(item: Item):
    _item_list.deselect_all()
    for index in _item_list.item_count:
        if _item_list.get_item_metadata(index) != item:
            continue
        _item_list.select(index)
        return

func deselect_item():
    _item_list.deselect_all()
#endregion

#region Private functions
func _connect_inventory_signals():
    if !is_instance_valid(inventory):
        return

    if !inventory.contents_changed.is_connected(_queue_refresh):
        inventory.contents_changed.connect(_queue_refresh)
    if !inventory.item_modified.is_connected(_on_item_modified):
        inventory.item_modified.connect(_on_item_modified)

func _disconnect_inventory_signals():
    if !is_instance_valid(inventory):
        return

    if inventory.contents_changed.is_connected(_queue_refresh):
        inventory.contents_changed.disconnect(_queue_refresh)
    if inventory.item_modified.is_connected(_on_item_modified):
        inventory.item_modified.disconnect(_on_item_modified)

func _on_list_item_activated(index: int):
    item_activated.emit(_get_item(index))

func _on_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int):
    if mouse_button_index == MOUSE_BUTTON_RIGHT:
        item_context_activated.emit(_get_item(index))

func _on_item_modified(_item: Item):
    _queue_refresh()

func _refresh():
    if is_inside_tree():
        _clear_list()
        _populate_list()

func _queue_refresh():
    _refresh_queued = true

func _clear_list():
    if is_instance_valid(_item_list):
        _item_list.clear()

func _populate_list():
    if !is_instance_valid(inventory):
        return

    for item in inventory.get_all_items():
        var texture: Texture2D = item.get_texture()
        if !texture:
            texture = default_item_icon
        _item_list.add_item(_get_item_title(item), texture)
        _item_list.set_item_metadata(_item_list.get_item_count() - 1, item)

func _get_item_title(item: Item) -> String:
    if item == null:
        return ""

    var title = item.get_title()
    var stack_size: int = InventoryStack.get_item_stack_size(item)
    if stack_size > 1:
        title = "%s (x%d)" % [title, stack_size]

    return title

func _get_item(index: int) -> Item:
    assert(index >= 0)
    assert(index < _item_list.get_item_count())

    return _item_list.get_item_metadata(index)
#endregion