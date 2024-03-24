class_name Count

#region Constants
const INF: int = -1
#endregion

#region Exported vars
@export var count: int = 0: 
    set(new_count):
        if new_count < 0:
            new_count = -1
        count = new_count
#endregion

#region Virtual functions
func _init(_count: int = 0):
    if _count < 0:
        _count = -1
    count = _count
#endregion

#region Public functions
func is_inf() -> bool:
    return count < 0

func add(_item_count: Count) -> Count:
    if _item_count.is_inf():
        count = INF
    elif !self.is_inf():
        count += _item_count.count
    return self

func mul(_item_count: Count) -> Count:
    if count == 0:
        return self
    elif _item_count.is_inf():
        count = INF
        return self
    elif _item_count.count == 0:
        count = 0
        return self
    elif self.is_inf():
        return self
    
    count *= _item_count.count
    return self

func less(compare_count: Count) -> bool:
    if compare_count.is_inf() && self.is_inf():
        return false
    elif compare_count.is_inf():
        return true
    elif self.is_inf():
        return false
    else:
        return count < compare_count.count
#endregion

#region Static functions
static func min(first_count: Count, second_count: Count) -> Count:
    return first_count if first_count.less(second_count) else second_count

static func zero() -> Count:
    return Count.new()

static func inf() -> Count:
    return Count.new(INF)
#endregion
