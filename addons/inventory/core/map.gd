class_name Map

#region Public vars
var map: Array
var free_fields:
    get:
        return _free_fields
    set(new_free_fields):
        assert(false, "Property free_fields is read-only")
#endregion

#region Private vars
var _free_fields: int
#endregion

#region Virtual functions
func _init(size: Vector2i):
    resize(size)
#endregion

#region Public functions
func resize(size: Vector2i):
    map = []
    map.resize(size.x)
    for i in map.size():
        map[i] = []
        map[i].resize(size.y)
    _free_fields = size.x * size.y

func fill_rect(rect: Rect2i, value):
    assert(value, "Cannot fill with null")
    _fill_rect_unsafe(rect, value)

func contains(position: Vector2i) -> bool:
    if map.is_empty():
        return false
    var size = get_size()
    return (
        position.x >= 0 && \
        position.y >= 0 && \
        position.x < size.x && \
        position.y < size.y
    )

func get_field(position: Vector2i) -> Variant:
    assert(contains(position), "Position {%s} out of bounds" % position)
    return map[position.x][position.y]

func get_size() -> Vector2i:
    return Vector2i(map.size(), map[0].size()) if !map.is_empty() else Vector2i.ZERO

func clear():
    for column in map:
        column.fill(null)
    var size = get_size()
    _free_fields = size.x * size.y

func clear_rect(rect: Rect2i):
    _fill_rect_unsafe(rect, null)

func print():
    if !map.is_empty():
        var output: String
        var size = get_size()

        for j in range(size.y):
            for i in range(size.x):
                if map[i][j]:
                    output += "X"
                else:
                    output += "."
            output += "\n"
        print(output + "\n")
#endregion

#region Private functions
func _fill_rect_unsafe(rect: Rect2i, value):
    for x in range(rect.size.x):
        for y in range(rect.size.y):
            var map_coords: Vector2i = Vector2i(rect.position.x + x, rect.position.y + y)
            if !contains(map_coords):
                continue
            if map[map_coords.x][map_coords.y] != value:
                if !value:
                    _free_fields += 1
                else:
                    _free_fields -= 1
                map[map_coords.x][map_coords.y] = value
#endregion