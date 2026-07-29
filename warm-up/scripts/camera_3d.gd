extends Camera3D

const RAY_LENGTH = 1000.0
var world_state:PhysicsDirectSpaceState3D

func _ready() -> void:
	world_state=get_world_3d().get_direct_space_state()

func _input(event: InputEvent) -> void:

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Camera click input event")
		var from = project_ray_origin(event.position)
		var to = from + project_ray_normal(event.position) * RAY_LENGTH
		print("from: ",from,";to: ",to)
		_find_object_hit(from,to)

func _find_object_hit(from:Vector3,to:Vector3)->void:
	var ray_query:PhysicsRayQueryParameters3D=PhysicsRayQueryParameters3D.create(from,to)
	var result_raw:Dictionary=world_state.intersect_ray(ray_query)
	if result_raw.is_empty():
		return
	var result:RayIntersectionResult=RayIntersectionResult.from_dict(result_raw)
	print(result.to_custom_string())
