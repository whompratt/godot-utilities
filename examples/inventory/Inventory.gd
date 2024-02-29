class_name Inventory

var name: String
var size: Vector2i
var contents: Array[Stack]

func _init(
	_name: String,
	_size: Vector2i,
):
	self.name = _name
	self.size = _size
	self.contents.resize(self.size.x * self.size.y)
