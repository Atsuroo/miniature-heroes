class_name  RaycastManager
extends Node

const RAY_LENGTH:float = 1000.0
const TILE_LAYER:int = 1 << 0
const MINI_LAYER:int = 1 << 1


var is_click_pending:bool=false

signal world_position_clicked(position_clicked:Vector3)
#Placeholder
signal mini_clicked()

signal hover_tile_position(position_hovered:Vector3)
signal hover_tile_leave()

@onready var viewport := get_viewport()
@onready var camera := viewport.get_camera_3d()
var collision_mask:int=TILE_LAYER | MINI_LAYER
var exclude_rids:Array[RID]=[]





func _physics_process(_delta: float) -> void:
	var world_state:PhysicsDirectSpaceState3D=viewport.get_world_3d().get_direct_space_state()
	var mouse_position:Vector2=viewport.get_mouse_position()
	var from:Vector3 = camera.project_ray_origin(mouse_position)
	var to:Vector3 = from + camera.project_ray_normal(mouse_position) * RAY_LENGTH

	var result:RayIntersectionResult=_get_ray_intersection(world_state,from,to)


	if is_click_pending:
		if result:
			if result.collider is CollisionObject3D:
				var body := result.collider as CollisionObject3D
				if body.collision_layer & TILE_LAYER != 0:
					world_position_clicked.emit(result.position)
				if body.collision_layer & MINI_LAYER != 0:
					#Placeholder
					mini_clicked.emit()

		is_click_pending=false



	_check_hover(result)

func _check_hover(result:RayIntersectionResult)->void:
	if result:
		if result.collider is CollisionObject3D:
			var body := result.collider as CollisionObject3D
			if body.collision_layer & TILE_LAYER != 0:
				hover_tile_position.emit(result.position)
	else:
		hover_tile_leave.emit()



func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:
		var mouse_event:InputEventMouseButton=event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			is_click_pending=true


func _get_ray_intersection(world_state:PhysicsDirectSpaceState3D,from:Vector3,to:Vector3)->RayIntersectionResult:
	var ray_query:PhysicsRayQueryParameters3D=PhysicsRayQueryParameters3D.create(from,to)
	ray_query.exclude=exclude_rids
	ray_query.collision_mask=collision_mask
	var result_raw:Dictionary=world_state.intersect_ray(ray_query)
	if result_raw.is_empty():
		return null
	var result:RayIntersectionResult=RayIntersectionResult.from_dict(result_raw)

	return result
