class_name Verify

#region Constants
const TYPE_NAMES: Array = [
    "null",
    "bool",
    "int",
    "float",
    "String",
    "Vector2",
    "Vector2i",
    "Rect2",
    "Rect2i",
    "Vector3",
    "Vector3i",
    "Transform2D",
    "Vector4",
    "Vector4i",
    "Plane",
    "Quaternion",
    "AABB",
    "Basis",
    "Transform3D",
    "Projection",
    "Color",
    "StringName",
    "NodePath",
    "RID",
    "Object",
    "Callable",
    "Signal",
    "Dictionary",
    "Array",
    "PackedByteArray",
    "PackedInt32Array",
    "PackedInt64Array",
    "PackedFloat32Array",
    "PackedFloat64Array",
    "PackedStringArray",
    "PackedVector2Array",
    "PackedVector3Array",
    "PackedColorArray",
]
#endregion

#region Public functions
static func create_var(type: int):
    match type:
        TYPE_BOOL:
            return false
        TYPE_INT:
            return 0
        TYPE_FLOAT:
            return 0.0
        TYPE_STRING:
            return ""
        TYPE_VECTOR2:
            return Vector2()
        TYPE_VECTOR2I:
            return Vector2i()
        TYPE_RECT2:
            return Rect2()
        TYPE_RECT2I:
            return Rect2i()
        TYPE_VECTOR3:
            return Vector3()
        TYPE_VECTOR3I:
            return Vector3i()
        TYPE_VECTOR4:
            return Vector4()
        TYPE_VECTOR4I:
            return Vector4i()
        TYPE_TRANSFORM2D:
            return Transform2D()
        TYPE_PLANE:
            return Plane()
        TYPE_QUATERNION:
            return Quaternion()
        TYPE_AABB:
            return AABB()
        TYPE_BASIS:
            return Basis()
        TYPE_TRANSFORM3D:
            return Transform3D()
        TYPE_PROJECTION:
            return Projection()
        TYPE_COLOR:
            return Color()
        TYPE_STRING_NAME:
            return ""
        TYPE_NODE_PATH:
            return NodePath()
        TYPE_RID:
            return RID()
        TYPE_OBJECT:
            return Object.new()
        TYPE_DICTIONARY:
            return {}
        TYPE_ARRAY:
            return []
        TYPE_PACKED_BYTE_ARRAY:
            return PackedByteArray()
        TYPE_PACKED_INT32_ARRAY:
            return PackedInt32Array()
        TYPE_PACKED_INT64_ARRAY:
            return PackedInt64Array()
        TYPE_PACKED_FLOAT32_ARRAY:
            return PackedFloat32Array()
        TYPE_PACKED_FLOAT64_ARRAY:
            return PackedFloat64Array()
        TYPE_PACKED_STRING_ARRAY:
            return PackedStringArray()
        TYPE_PACKED_VECTOR2_ARRAY:
            return PackedVector2Array()
        TYPE_PACKED_VECTOR3_ARRAY:
            return PackedVector3Array()
        TYPE_PACKED_COLOR_ARRAY:
            return PackedColorArray()
        _:
            return null

static func dict(
    dictionary: Dictionary,
    mandatory: bool,
    key: String,
    expected_value_type,
    expected_array_type: int=- 1
) -> bool:
    if !dictionary.has(key):
        if !mandatory:
            return true
        push_warning("Missing key '%s'" % key)
        return false
    
    if expected_value_type is int:
        return _check_dict_key_type(
            dictionary,
            key,
            expected_value_type,
            expected_array_type
        )
    elif expected_value_type is Array:
        return _check_dict_key_type_multi(
            dictionary,
            key,
            expected_value_type
        )
    
    push_warning("Dictionary's 'value_type' must be int or Array")
    return false

static func vector_positive(vector) -> bool:
    assert(vector is Vector2 || vector is Vector2i, "Input [param vector] must be Vector2 or Vector2i")
    return vector.x >= 0 && vector.y >= 0

static func rect_positive(rect: Rect2) -> bool:
    return vector_positive(rect.position) && vector_positive(rect.size)
#endregion

#region Private functions
static func _check_dict_key_type(
    dictionary: Dictionary,
    key: String,
    expected_value_type: int,
    expected_array_type: int=- 1
) -> bool:
    var type: int = typeof(dictionary[key])
    if type != expected_value_type:
        push_warning("Value at key '%s' has wrong type, expected {%s}, got {%s}", [
            key,
            type_string(expected_value_type),
            type_string(type)
        ])
        return false
    if expected_value_type == TYPE_ARRAY && expected_array_type >= 0:
        return _check_dict_key_array_type(
            dictionary,
            key,
            expected_array_type
        )
    return true

static func _check_dict_key_array_type(
    dictionary: Dictionary,
    key: String,
    expected_array_type: int
) -> bool:
    var array: Array = dictionary[key]
    for i in range(array.size()):
        if typeof(array[i]) != expected_array_type:
            push_warning("Array element %d has wrong type, expected {%s}, got {%s}" % [
                i,
                type_string(expected_array_type),
                type_string(array[i])
            ])
            return false
    return true

static func _check_dict_key_type_multi(
    dictionary: Dictionary,
    key: String,
    expected_value_types: Array
) -> bool:
    var t: int = typeof(dictionary[key])
    var expected_value_type_strings: Array[String] = []
    for type in expected_value_types:
        expected_value_type_strings.append(type_string(type))
    if !(t in expected_value_types):
        push_warning("Value at key '%s' has wrong type, got {%s}, but expected one of {%s}", [
            key,
            type_string(t),
            expected_value_type_strings
        ])
        return false
    return true
#endregion