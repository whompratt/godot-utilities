class_name ValueEditor extends MarginContainer

#region Signals
signal value_changed
#endregion

#region Public vars
var value:
    set(new_value):
        value = new_value
        call_deferred("_refresh")
var enabled: bool = true
#endregion

#region Virtual functions
func _ready():
    _refresh()
#endregion

#region Private functions
func _refresh():
    _clear()
    _add_control()

func _clear():
    for child in get_children():
        child.queue_free()

func _add_control():
    var type = typeof(value)
    var control: Control = null

    match type:
        TYPE_COLOR:
            control = _create_color_picker()
        TYPE_BOOL:
            control = _create_checkbox()
        TYPE_VECTOR2:
            control = _create_vector2_editor()
        TYPE_VECTOR2I:
            control = _create_vector2i_editor()
        TYPE_VECTOR3:
            control = _create_vector3_editor()
        TYPE_VECTOR3I:
            control = _create_vector3i_editor()
        TYPE_RECT2:
            control = _create_rect2_editor()
        TYPE_RECT2I:
            control = _create_rect2i_editor()
        TYPE_PLANE:
            control = _create_plane_editor()
        TYPE_QUATERNION:
            control = _create_quat_editor()
        TYPE_AABB:
            control = _create_aabb_editor()
        _:
            control = _create_line_edit()
    
    add_child(control)

func _create_line_edit() -> LineEdit:
    var line_edit: LineEdit = LineEdit.new()
    line_edit.text = var_to_str(value)
    line_edit.editable = enabled
    _expand_control(line_edit)
    line_edit.text_submitted.connect(_on_line_edit_value_entered.bind(line_edit))
    line_edit.focus_exited.connect(_on_line_edit_focus_exited.bind(line_edit))
    return line_edit

func _on_line_edit_value_entered(_text: String, line_edit: LineEdit):
    _on_line_edit_focus_exited(line_edit)

func _on_line_edit_focus_exited(line_edit: LineEdit):
    var new_value = str_to_var(line_edit.text)
    if typeof(new_value) != typeof(value):
        line_edit.text = var_to_str(value)
        return
    value = new_value
    value_changed.emit()

func _create_color_picker() -> ColorPickerButton:
    var picker: ColorPickerButton = ColorPickerButton.new()
    picker.color = value
    picker.disabled = !enabled
    _expand_control(picker)
    picker.popup_closed.connect(_on_color_picked.bind(picker))
    return picker

func _on_color_picked(picker: ColorPickerButton):
    value = picker.color
    value_changed.emit()

func _create_checkbox() -> CheckButton:
    var checkbox: CheckButton = CheckButton.new()
    checkbox.button_pressed = value
    checkbox.disabled = !enabled
    _expand_control(checkbox)
    checkbox.pressed.connect(_on_checkbox.bind(checkbox))
    return checkbox

func _on_checkbox(checkbox: CheckButton):
    value = checkbox.button_pressed
    value_changed.emit()

func _create_vector2_editor() -> Control:
    var values = [value.x, value.y]
    var titles = ["X", "Y"]
    var vector2_editor = _create_multifloat_editor(2, enabled, values, titles, _on_vector2_value_changed)
    return vector2_editor

func _create_vector2i_editor() -> Control:
    var values = [value.x, value.y]
    var titles = ["X", "Y"]
    var vector2i_editor = _create_multiint_editor(2, enabled, values, titles, _on_vector2_value_changed)
    return vector2i_editor

func _on_vector2_value_changed(_index: int, vector2_editor: Control):
    value.x = vector2_editor.values[0]
    value.y = vector2_editor.values[1]
    value_changed.emit()

func _create_vector3_editor() -> Control:
    var values = [value.x, value.y, value.z]
    var titles = ["X", "Y", "Z"]
    var vector3_editor = _create_multifloat_editor(3, enabled, values, titles, _on_vector3_value_changed)
    return vector3_editor

func _create_vector3i_editor() -> Control:
    var values = [value.x, value.y, value.z]
    var titles = ["X", "Y", "Z"]
    var vector3i_editor = _create_multiint_editor(3, enabled, values, titles, _on_vector3_value_changed)
    return vector3i_editor

func _on_vector3_value_changed(_index: int, vector3_editor: Control):
    value.x = vector3_editor.values[0]
    value.y = vector3_editor.values[1]
    value.z = vector3_editor.values[2]
    value_changed.emit()

func _create_rect2_editor() -> Control:
    var values = [value.position.x, value.position.y, value.size.x, value.size.y]
    var titles = ["Position X", "Position Y", "Size X", "Size Y"]
    var rect2_editor = _create_multifloat_editor(2, enabled, values, titles, _on_rect2_value_changed)
    return rect2_editor

func _create_rect2i_editor() -> Control:
    var values = [value.position.x, value.position.y, value.size.x, value.size.y]
    var titles = ["Position X", "Position Y", "Size X", "Size Y"]
    var rect2_editor = _create_multiint_editor(2, enabled, values, titles, _on_rect2_value_changed)
    return rect2_editor

func _on_rect2_value_changed(_index: int, rect2_editor: Control):
    value.position.x = rect2_editor.values[0]
    value.position.y = rect2_editor.values[1]
    value.size.x = rect2_editor.values[2]
    value.size.y = rect2_editor.values[3]

func _create_plane_editor() -> Control:
    var values = [value.x, value.y, value.z, value.d]
    var titles = ["X", "Y", "Z", "D"]
    var plane_editor = _create_multifloat_editor(2, enabled, values, titles, _on_plane_value_changed)
    return plane_editor

func _on_plane_value_changed(_index: int, plane_editor: Control):
    value.x = plane_editor.values[0]
    value.y = plane_editor.values[1]
    value.z = plane_editor.values[2]
    value.d = plane_editor.values[3]
    value_changed.emit()

func _create_quat_editor() -> Control:
    var values = [value.x, value.y, value.z, value.w]
    var titles = ["X", "Y", "Z", "W"]
    var quat_editor = _create_multifloat_editor(2, enabled, values, titles, _on_quat_value_changed)
    return quat_editor

func _on_quat_value_changed(_index: int, quat_editor: Control):
    value.x = quat_editor.values[0]
    value.y = quat_editor.values[1]
    value.z = quat_editor.values[2]
    value.d = quat_editor.values[3]

func _create_aabb_editor() -> Control:
    var values = [value.position.x, value.position.y, value.position.z, value.size.x, value.size.y, value.size.z]
    var titles = ["Position X", "Position Y", "Position Z", "Size X", "Size Y", "Size Z"]
    var aabb_editor = _create_multifloat_editor(3, enabled, values, titles, _on_aabb_value_changed)
    return aabb_editor

func _on_aabb_value_changed(_index: int, aabb_editor: Control):
    value.position.x = aabb_editor.values[0]
    value.position.y = aabb_editor.values[1]
    value.position.z = aabb_editor.values[2]
    value.size.x = aabb_editor.values[3]
    value.size.y = aabb_editor.values[4]
    value.size.z = aabb_editor.values[5]
    value_changed.emit()

func _create_multifloat_editor(columns: int, enabled: bool, values: Array, titles: Array, value_changed_handler: Callable) -> Control:
    return _create_multivalue_editor(columns, enabled, TYPE_FLOAT, values, titles, value_changed_handler)

func _create_multiint_editor(columns: int, enabled: bool, values: Array, titles: Array, value_changed_handler: Callable) -> Control:
    return _create_multivalue_editor(columns, enabled, TYPE_INT, values, titles, value_changed_handler)

func _create_multivalue_editor(columns: int, enabled: bool, type: int, values: Array, titles: Array, value_changed_handler: Callable) -> Control:
    var multivalue_editor = MultivalueEditor.new()
    multivalue_editor.columns = columns
    multivalue_editor.enabled = enabled
    multivalue_editor.type = type
    multivalue_editor.values = values
    multivalue_editor.titles = titles
    _expand_control(multivalue_editor)
    multivalue_editor.value_changed.connect(value_changed_handler.bind(multivalue_editor))
    return multivalue_editor

func _expand_control(control: Control):
    control.size_flags_horizontal = SIZE_EXPAND_FILL
    control.anchor_right = 1.0
    control.anchor_bottom = 1.0
#endregion