@tool
extends Button

#region Vars
@onready var window_dialog: Window = $"%Window"
@onready var protoset_editor: Control = $"%ProtosetEditor"

var protoset: Protoset:
	set(new_protoset):
		protoset = new_protoset
		if protoset_editor:
			protoset_editor.protoset = protoset
#endregion

#region Virtual functions
func _ready():
	window_dialog.close_requested.connect(func(): protoset.notify_property_list_changed())
	protoset_editor.protoset = protoset
	pressed.connect(func(): window_dialog.popup_centered(window_dialog.size))
#endregion

#region Public functions
func init(_protoset: Protoset):
	protoset = _protoset
#endregion
