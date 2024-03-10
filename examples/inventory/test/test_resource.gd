class_name TestResource extends Resource

@export var test_json: JSON:
	set(new_json):
		test_json = new_json
		if test_json:
			update_data()
		_save()

@export var test_data: Dictionary:
	set(new_data):
		test_data = new_data
		if test_data:
			update_json()
		_save()

func _save():
	print("saving")
	if !resource_path.is_empty():
		print(resource_path)
		ResourceSaver.save(self)

func update_data():
	test_data.clear()
	if test_json.data:
		for item in test_json.data:
			test_data[item.name] = item

func update_json():
	var json: Array[Dictionary] = []
	if test_data:
		for item in test_data:
			json.append(test_data[item])
		test_json.data = json
