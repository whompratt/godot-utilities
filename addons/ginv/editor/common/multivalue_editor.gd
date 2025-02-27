class_name MultivalueEditor extends GridContainer

#region Signals
signal value_changed(index)
#endregion

#region Public vars
var values: Array = []:
    set(new_values):
        assert(!is_inside_tree())
        values = new_values
var titles: Array = []:
    set(new_titles):
        assert(!is_inside_tree())
        titles = new_titles
var enabled: bool = true
var type: int = TYPE_FLOAT
#endregion

#region Virtual functions
func _ready():
    for i in values.size():
        var hbox: HBoxContainer = HBoxContainer.new()
        hbox.size_flags_horizontal = SIZE_EXPAND_FILL

        if i < titles.size():
            var label: Label = Label.new()
            label.text = "%s:" % titles[i]
            hbox.add_child(label)
        else:
            var dummy: Control = Control.new()
            hbox.add_child(dummy)
        
        var line_edit: LineEdit = LineEdit.new()
        line_edit.text = var_to_str(values[i])
        line_edit.size_flags_horizontal = SIZE_EXPAND_FILL
        line_edit.text_submitted.connect(_on_line_edit_value_entered.bind(line_edit, i))
        line_edit.focus_exited.connect(_on_line_edit_focus_exited.bind(line_edit, i))
        line_edit.editable = enabled
        hbox.add_child(line_edit)

        add_child(hbox)
#endregion

#region Private functions
func _on_line_edit_value_entered(_text: String, line_edit: LineEdit, index: int):
    _on_line_edit_focus_exited(line_edit, index)

func _on_line_edit_focus_exited(line_edit: LineEdit, index: int):
    var value = str_to_var(line_edit.text)
    if typeof(value) != type:
        line_edit.text = var_to_str(values[index])
    else:
        values[index] = value
        value_changed.emit(index)
#endregion