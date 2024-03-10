@tool
class_name TestNode extends Node

@export var test_resource: TestResource = TestResource.new()
@export var output_debug: bool:
	set(new):
		print_resource()
@export var update_json: bool:
	set(new):
		test_resource.update_json()
@export var update_data: bool:
	set(new):
		test_resource.update_data()

func print_resource():
	print("-- Resource JSON --")
	var ref_json = test_resource.test_json.data
	print(ref_json)
	
	print("-- Resource DATA --")
	var ref_data = test_resource.test_data
	print(ref_data)
