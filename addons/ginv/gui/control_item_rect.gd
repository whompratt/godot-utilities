class_name ControlItemRect extends ControlDraggable

#region Signals
signal activated
signal context_activated
#endregion

#region Public vars
var item: Item:
    set(new_item):
        if item == new_item:
            return

        _disconnect_item_signals()
        _connect_item_signals(new_item)
        item = new_item

        if item:
            texture = item.get_texture()
            activate()
        else:
            texture = null
            deactivate()

var texture: Texture2D:
    set(new_texture):
        if texture == new_texture:
            return
        texture = new_texture
        _update_texture()

var selected: bool = false:
    set(new_selected):
        if selected == new_selected:
            return
        selected = new_selected
        _update_selection()

var selection_background_color: Color = Color.GRAY:
    set(new_selection_background_color):
        if new_selection_background_color == selection_background_color:
            return
        selection_background_color = new_selection_background_color
        _update_selection()

var stretch_mode: TextureRect.StretchMode = TextureRect.StretchMode.STRETCH_SCALE:
    set(new_stretch_mode):
        if stretch_mode == new_stretch_mode:
            return
        stretch_mode = new_stretch_mode
        if is_instance_valid(_texture_rect):
            _texture_rect.stretch_mode = stretch_mode
            
var slot: Slot
#endregion

#region Private vars
var _selection_rect: ColorRect
var _texture_rect: TextureRect
var _stack_size_label: Label
static var _stored_preview_size: Vector2
static var _stored_preview_offset: Vector2
#endregion

#region Virtual functions
func _ready():
    drag_preview = ControlItemRect.new()

    _selection_rect = ColorRect.new()
    _selection_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _texture_rect = TextureRect.new()
    _texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _texture_rect.stretch_mode = stretch_mode
    _stack_size_label = Label.new()
    _stack_size_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _stack_size_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    _stack_size_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
    add_child(_selection_rect)
    add_child(_texture_rect)
    add_child(_stack_size_label)

    resized.connect(func():
        _selection_rect.size = size
        _texture_rect.size = size
        _stack_size_label.size = size
    )

    if !item:
        deactivate()

    _refresh()

func drag_start():
    if set_drag_preview:
        drag_preview.item = item
        drag_preview.texture = texture
        drag_preview.size = size
        drag_preview.stretch_mode = stretch_mode
        
    super.drag_start()

func get_stretched_texture_size(container_size: Vector2) -> Vector2:
    if !texture:
        return Vector2.ZERO

    match stretch_mode:
        TextureRect.StretchMode.STRETCH_TILE, TextureRect.StretchMode.STRETCH_SCALE:
            return container_size
        TextureRect.StretchMode.STRETCH_KEEP, TextureRect.StretchMode.STRETCH_KEEP_CENTERED:
            return texture.get_size()
        TextureRect.StretchMode.STRETCH_KEEP_ASPECT, TextureRect.StretchMode.STRETCH_KEEP_ASPECT_CENTERED, TextureRect.StretchMode.STRETCH_KEEP_ASPECT_COVERED:
            return size

    return Vector2.ZERO
#endregion

#region Private functions
func _connect_item_signals(new_item: Item):
    if !new_item:
        return

    if !new_item.protoset_changed.is_connected(_refresh):
        new_item.protoset_changed.connect(_refresh)
    if !new_item.prototype_id_changed.is_connected(_refresh):
        new_item.prototype_id_changed.connect(_refresh)
    if !new_item.properties_changed.is_connected(_refresh):
        new_item.properties_changed.connect(_refresh)

func _disconnect_item_signals():
    if !is_instance_valid(item):
        return

    if item.protoset_changed.is_connected(_refresh):
        item.protoset_changed.disconnect(_refresh)
    if item.prototype_id_changed.is_connected(_refresh):
        item.prototype_id_changed.disconnect(_refresh)
    if item.properties_changed.is_connected(_refresh):
        item.properties_changed.disconnect(_refresh)

func _get_item_position() -> Vector2:
    if is_instance_valid(item) && item.get_inventory():
        return item.get_inventory().get_item_position(item)
    return Vector2(0, 0)

func _update_selection():
    if !is_instance_valid(_selection_rect):
        return
    _selection_rect.visible = selected
    _selection_rect.color = selection_background_color
    _selection_rect.size = size

func _update_texture():
    if !is_instance_valid(_texture_rect):
        return

    _texture_rect.texture = texture

    if is_instance_valid(item) && ConstraintGrid.is_item_rotated(item):
        _texture_rect.size = Vector2(size.y, size.x)

        if ConstraintGrid.is_item_rotation_positive(item):
            _texture_rect.position = Vector2(_texture_rect.size.y, 0)
            _texture_rect.rotation = PI/2
        else:
            _texture_rect.position = Vector2(0, _texture_rect.size.x)
            _texture_rect.rotation = -PI/2
    else:
        _texture_rect.size = size
        _texture_rect.position = Vector2.ZERO
        _texture_rect.rotation = 0

func _update_stack_size():
    if !is_instance_valid(_stack_size_label):
        return
    if !is_instance_valid(item):
        _stack_size_label.text = ""
        return

    var stack_size: int = ConstraintStack.get_item_stack_size(item)

    if stack_size <= 1:
        _stack_size_label.text = ""
    else:
        _stack_size_label.text = "%d" % stack_size

    _stack_size_label.size = size

func _refresh():
    _update_selection()
    _update_texture()
    _update_stack_size()

func _gui_input(event: InputEvent):
    super._gui_input(event)

    if !(event is InputEventMouseButton):
        return

    var mouse_button_event: InputEventMouseButton = event

    if mouse_button_event.button_index == MOUSE_BUTTON_LEFT && mouse_button_event.double_click:
        activated.emit()
    elif mouse_button_event.button_index == MOUSE_BUTTON_MASK_RIGHT:
        context_activated.emit()
#endregion