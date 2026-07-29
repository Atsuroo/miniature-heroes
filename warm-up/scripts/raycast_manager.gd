class_name  RaycastManager
extends Node

const RAY_LENGTH:float = 1000.0
const FLOOR_LAYER:int = 1 << 0
const CUBE_LAYER:int = 1 << 1
@export var player_collision:CollisionObject3D

@onready var viewport := get_viewport()
@onready var camera := viewport.get_camera_3d()

var from:Vector3 = Vector3.ZERO
var to:Vector3 = Vector3.ZERO
var player_collision_rid:RID
var is_click_pending:bool=false

signal world_position_clicked(position_clicked:Vector3)


func _ready() -> void:
	player_collision_rid=player_collision.get_rid()

func _physics_process(_delta: float) -> void:
	if is_click_pending:
		var world_state:PhysicsDirectSpaceState3D=viewport.get_world_3d().get_direct_space_state()
		var result:RayIntersectionResult=_get_ray_intersection(world_state)
		if result:
			if result.collider.collision_layer & FLOOR_LAYER != 0:
				world_position_clicked.emit(result.position)

		from=Vector3.ZERO
		to=Vector3.ZERO
		is_click_pending=false

func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and to==Vector3.ZERO:
		from = camera.project_ray_origin(event.position)
		to = from + camera.project_ray_normal(event.position) * RAY_LENGTH
		is_click_pending=true



func _get_ray_intersection(world_state:PhysicsDirectSpaceState3D)->RayIntersectionResult:
	var ray_query:PhysicsRayQueryParameters3D=PhysicsRayQueryParameters3D.create(from,to)
	ray_query.exclude=[player_collision_rid]
	ray_query.collision_mask=FLOOR_LAYER | CUBE_LAYER
	var result_raw:Dictionary=world_state.intersect_ray(ray_query)
	if result_raw.is_empty():
		return null
	var result:RayIntersectionResult=RayIntersectionResult.from_dict(result_raw)

	return result
