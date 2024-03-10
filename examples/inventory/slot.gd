@tool
class_name Slot extends SlotBase

@export var item_protoset: Protoset:
    set(new_item_protoset):
        if new_item_protoset == item_protoset:
            return
        # if _item:
        #     _item == null
        item_protoset = new_item_protoset
        # protoset_changed.emit()
        update_configuration_warnings()