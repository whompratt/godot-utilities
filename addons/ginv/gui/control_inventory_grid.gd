@tool
class_name ControlInventoryGrid extends Control

#region Signals
signal item_dropped(item, offset)
signal selection_changed
signal inventory_item_activated(item)
signal inventory_item_context_activated(item)
signal item_mouse_entered(item)
signal item_mouse_exited(item)
#endregion

#region Exported vars
@export var field_dimensions: Vector2 = Vector2(32, 32):
    set(new_field_dimensions):
        field_dimensions = new_field_dimensions
        _queue_refresh()
@export var item_spacing: int = 0:
    set(new_item_spacing):
        item_spacing = new_item_spacing
        _queue_refresh()
@export var draw_grid: bool = true:
    set(new_draw_grid):
        draw_grid = new_draw_grid
        _queue_refresh()
@export var grid_color: Color = Color.BLACK:
    set(new_grid_color):
        grid_color = new_grid_color
        _queue_refresh()
@export var draw_selections: bool = false:
    set(new_draw_selections):
        draw_selections = new_draw_selections
@export var selection_color: Color = Color.GRAY
@export var inventory_path: NodePath:
    set(new_inventory_path):
        inventory_path = new_inventory_path
        var node: Node = get_node_or_null(inventory_path)
        if node == null:
            return
        if is_inside_tree():
            assert(node is InventoryGrid, "Assigned inventory not grid type")
        inventory = node
        update_configuration_warnings()
@export var default_item_texture: Texture2D :
    set(new_default_item_texture):
        default_item_texture = new_default_item_texture
        _queue_refresh()
@export var stretch_item_sprites: bool = true :
    set(new_stretch_item_sprites):
        stretch_item_sprites = new_stretch_item_sprites
        _queue_refresh()
@export var drag_sprite_z_index: int = 1
#endregion

#region Public vars
var inventory: InventoryGrid = null:
    set(new_inventory):
        if inventory != new_inventory:
            _select(null)
            _disconnect_inventory_signals()
            inventory = new_inventory
            _connect_inventory_signals()
            _queue_refresh()
#endregion

#region Private vars
var _control_item_container: Control = null
var _control_drop_zone: ControlDropZone = null
var _selected_item: Item = null
var _refresh_queued: bool = false
#endregion

#region Virtual functions
func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []

    if inventory_path.is_empty():
        warnings.append("Node has no inventory, set inventory_path to an InventoryGrid node")

    return warnings

func _ready():
    if Engine.is_editor_hint():
        if is_instance_valid(_control_item_container):
            _control_item_container.queue_free()

    _control_item_container = Control.new()
    _control_item_container.size_flags_horizontal = SIZE_EXPAND_FILL
    _control_item_container.size_flags_vertical = SIZE_EXPAND_FILL
    _control_item_container.anchor_right = 1.0
    _control_item_container.anchor_bottom = 1.0
    add_child(_control_item_container)
    _control_drop_zone = ControlDropZone.new()
    _control_drop_zone.draggable_dropped.connect(_on_draggable_dropped)
    _control_drop_zone.size = size
    resized.connect(func(): _control_drop_zone.size = size)

    ControlDraggable.draggable_grabbed.connect(func(draggable: ControlDraggable, grab_position: Vector2):
        _control_drop_zone.activate()
    )
    ControlDraggable.draggable_dropped.connect(func(draggable: ControlDraggable, zone: ControlDropZone, drop_position: Vector2):
        _control_drop_zone.deactivate()
    )

    add_child(_control_drop_zone)

    _control_item_container.resized.connect(func(): _control_drop_zone.size = _control_item_container.size)

    if has_node(inventory_path):
        inventory = get_node_or_null(inventory_path)

    _queue_refresh()

func _process(_delta):
    if _refresh_queued:
        _refresh()
        _refresh_queued = false
#endregion

#region Public functions
func get_field_coords(local_pos: Vector2) -> Vector2i:
    var field_dimensions_ex = field_dimensions + Vector2(item_spacing, item_spacing)
    var local_pos_ex = local_pos + (Vector2(item_spacing, item_spacing) / 2)
    var x: int = local_pos_ex.x / (field_dimensions_ex.x)
    var y: int = local_pos_ex.y / (field_dimensions_ex.y)
    return Vector2i(x, y)

func get_selected_item() -> Item:
    return _selected_item

func deselect_inventory_item():
    _select(null)

func select_inventory_item(item: Item):
    _select(item)
#endregion

#region Private functions
func _connect_inventory_signals():
    if !is_instance_valid(inventory):
        return

    if !inventory.contents_changed.is_connected(_queue_refresh):
        inventory.contents_changed.connect(_queue_refresh)
    if !inventory.item_modified.is_connected(_on_item_modified):
        inventory.item_modified.connect(_on_item_modified)
    if !inventory.size_changed.is_connected(_on_inventory_resized):
        inventory.size_changed.connect(_on_inventory_resized)
    if !inventory.item_removed.is_connected(_on_item_removed):
        inventory.item_removed.connect(_on_item_removed)

func _disconnect_inventory_signals():
    if !is_instance_valid(inventory):
        return

    if inventory.contents_changed.is_connected(_queue_refresh):
        inventory.contents_changed.disconnect(_queue_refresh)
    if inventory.item_modified.is_connected(_on_item_modified):
        inventory.item_modified.disconnect(_on_item_modified)
    if inventory.size_changed.is_connected(_on_inventory_resized):
        inventory.size_changed.disconnect(_on_inventory_resized)
    if inventory.item_removed.is_connected(_on_item_removed):
        inventory.item_removed.disconnect(_on_item_removed)

func _on_item_modified(_item: Item):
    _queue_refresh()

func _on_inventory_resized():
    _queue_refresh()

func _on_item_removed(_item: Item):
    if _item == _selected_item:
        _select(null)

func _queue_refresh():
    _refresh_queued = true

func _refresh():
    _control_drop_zone.deactivate()
    _refresh_grid_container()
    _clear_list()
    _populate_list()
    queue_redraw()

func _draw():
    if !is_instance_valid(inventory):
        return
    if draw_grid:
        _draw_grid(Vector2.ZERO, inventory.size.x, inventory.size.y, field_dimensions, item_spacing)

func _draw_grid(pos: Vector2, w: int, h: int, fsize: Vector2, spacing: int):
    if w <= 0 || h <= 0 || spacing < 0:
        return

    if spacing <= 1:
        var rect = Rect2(pos, _get_inventory_size_px())
        draw_rect(rect, grid_color, false)
        for i in range(w):
            var from: Vector2 = Vector2(i * fsize.x, 0) + pos
            var to: Vector2 = Vector2(i * fsize.x, rect.size.y) + pos
            from += Vector2(spacing, 0)
            to += Vector2(spacing, 0)
            draw_line(from, to, grid_color)
        for j in range(h):
            var from: Vector2 = Vector2(0, j * fsize.y) + pos
            var to: Vector2 = Vector2(rect.size.x, j * fsize.y) + pos
            from += Vector2(0, spacing)
            to += Vector2(0, spacing)
            draw_line(from, to, grid_color)
    else:
        for i in range(w):
            for j in range(h):
                var field_pos = pos + Vector2(i * fsize.x, j * fsize.y) + Vector2(i, j) * spacing
                var field_rect = Rect2(field_pos, fsize)
                draw_rect(field_rect, grid_color, false)

func _get_inventory_size_px() -> Vector2:
    var result := Vector2(inventory.size.x * field_dimensions.x, \
        inventory.size.y * field_dimensions.y)

    result += Vector2(inventory.size - Vector2i.ONE) * item_spacing

    return result

func _refresh_grid_container():
    if !is_instance_valid(inventory):
        return

    custom_minimum_size = _get_inventory_size_px()
    size = custom_minimum_size

func _clear_list():
    if !is_instance_valid(_control_item_container):
        return

    for control_item_rect in _control_item_container.get_children():
        _control_item_container.remove_child(control_item_rect)
        control_item_rect.queue_free()

func _populate_list():
    if !is_instance_valid(inventory) || !is_instance_valid(_control_item_container):
        return
        
    for item in inventory.get_items():
        var control_item_rect = ControlItemRect.new()
        control_item_rect.texture = default_item_texture
        control_item_rect.item = item
        control_item_rect.drag_z_index = drag_sprite_z_index
        control_item_rect.grabbed.connect(_on_item_grab.bind(control_item_rect))
        control_item_rect.dropped.connect(_on_item_drop.bind(control_item_rect))
        control_item_rect.activated.connect(_on_item_activated.bind(control_item_rect))
        control_item_rect.context_activated.connect(_on_item_context_activated.bind(control_item_rect))
        control_item_rect.mouse_entered.connect(_on_item_mouse_entered.bind(control_item_rect))
        control_item_rect.mouse_exited.connect(_on_item_mouse_exited.bind(control_item_rect))
        control_item_rect.size = _get_item_sprite_size(item)

        control_item_rect.position = _get_field_position(inventory.get_item_position(item))
        if !stretch_item_sprites:
            control_item_rect.position += _get_unstreched_sprite_offset(item)

        _control_item_container.add_child(control_item_rect)

    _refresh_selection()

func _refresh_selection():
    if !draw_selections:
        return
    if !is_instance_valid(_control_item_container):
        return

    for control_item in _control_item_container.get_children():
        control_item.selected = control_item.item && (control_item.item == _selected_item)
        control_item.selection_bg_color = selection_color

func _on_item_grab(offset: Vector2, control_item_rect: ControlItemRect):
    _select(null)

func _on_item_drop(zone: ControlDropZone, drop_position: Vector2, control_item_rect: ControlItemRect):
    var item = control_item_rect.item
    if is_instance_valid(item) and inventory.has_item(item):
        _select(item)

func _get_item_sprite_size(item: Item) -> Vector2:
    if stretch_item_sprites:
        return _get_streched_item_sprite_size(item)
    else:
        return item.get_texture().get_size()

func _get_streched_item_sprite_size(item: Item) -> Vector2:
    var item_size := inventory.get_item_size(item)
    var sprite_size := Vector2(item_size) * field_dimensions

    sprite_size += (Vector2(item_size) - Vector2.ONE) * item_spacing

    return sprite_size

func _get_unstreched_sprite_offset(item: Item) -> Vector2:
    var texture = item.get_texture()
    if !texture:
        texture = default_item_texture
    if !texture:
        return Vector2.ZERO
    return (_get_streched_item_sprite_size(item) - texture.get_size()) / 2

func _on_item_activated(control_item_rect: ControlItemRect):
    var item = control_item_rect.item
    if !item:
        return

    inventory_item_activated.emit(item)

func _on_item_context_activated(control_item_rect: ControlItemRect):
    var item = control_item_rect.item
    if !item:
        return

    inventory_item_context_activated.emit(item)

func _on_item_mouse_entered(control_item_rect: ControlItemRect):
    item_mouse_entered.emit(control_item_rect.item)

func _on_item_mouse_exited(control_item_rect: ControlItemRect):
    item_mouse_exited.emit(control_item_rect.item)

func _select(item: Item):
    if item == _selected_item:
        return

    _selected_item = item
    _refresh_selection()
    selection_changed.emit()

func _on_draggable_dropped(draggable: ControlDraggable, drop_position: Vector2):
    var item: Item = draggable.item
    if !item:
        return

    if !is_instance_valid(inventory):
        return

    if inventory.has_item(item):
        _handle_item_move(item, drop_position)
    else:
        _handle_item_transfer(item, drop_position)

func _handle_item_move(item: Item, drop_position: Vector2):
    var field_coords = get_field_coords(drop_position + (field_dimensions / 2))
    if inventory.rect_free(Rect2i(field_coords, inventory.get_item_size(item)), item):
        _move_item(item, field_coords)
    elif inventory is InventoryGridStack:
        _merge_item(item, field_coords)

func _handle_item_transfer(item: Item, drop_position: Vector2):
    var source_inventory: InventoryGrid = item.get_inventory()
    
    var field_coords = get_field_coords(drop_position + (field_dimensions / 2))
    if source_inventory != null:
        if source_inventory.protoset != inventory.protoset:
            return
        source_inventory.transfer_to(item, inventory, field_coords)
    else:
        inventory.add_item_at(item, field_coords)

func _move_item(item: Item, move_position: Vector2i):
    if Engine.is_editor_hint():
        GInvUndoRedo.move_item(inventory, item, move_position)
    else:
        inventory.move_item_to(item, move_position)
        
func _merge_item(item_source: Item, position: Vector2i):
    var item_destination = (inventory as InventoryGridStack)._get_mergeable_item_at(item_source, position)
    if !item_destination:
        return

    if Engine.is_editor_hint():
        GInvUndoRedo.join_items(inventory, item_destination, item_source)
    else:
        (inventory as InventoryGridStack).join(item_source, item_destination)

func _get_field_position(field_coords: Vector2i) -> Vector2:
    var field_position = Vector2(field_coords.x * field_dimensions.x, \
        field_coords.y * field_dimensions.y)
    field_position += Vector2(item_spacing * field_coords)
    return field_position

func _get_global_field_position(field_coords: Vector2i) -> Vector2:
    return _get_field_position(field_coords) + global_position
#endregion








