@tool
class_name Slot extends SlotBase

@export var protoset: Protoset:
    set(new_protoset):
        if new_protoset == protoset:
            return
        # if _item:
        #     _item == null
        protoset = new_protoset
        # protoset_changed.emit()
        update_configuration_warnings()