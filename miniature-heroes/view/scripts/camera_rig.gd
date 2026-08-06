extends Node3D


@export var inner_gimbal:Node3D
@export var camera:Camera3D

@export_range(1, 100) var CAMERA_ROTATION_SPEED_CONFIG:float=10.0
var CAMERA_ROTATION_SPEED:float=0.001
@export var CAMERA_SCROLL_SPEED:float=2.0
@export var CAMERA_SPEED:int=10


@export_range(-89.0, 0.0)
var CAMERA_START_ANGLE: float = -45.0
@export_range(-89.0, 0.0)
var CAMERA_MIN_ANGLE_DEG: float = -80.0
@export_range(-89.0, 0.0)
var CAMERA_MAX_ANGLE_DEG: float = -10.0

var CAMERA_MIN_ANGLE: float=0.0
var CAMERA_MAX_ANGLE: float=0.0

var x_rotation_pending:float=0.0
var y_rotation_pending:float=0.0

@export_range(1.0, 100.0) var ZOOM_START:float=5.0
@export var ZOOM_STEP:float=1.0
var zoom_distance:float
var zoom_target :float
@export var zoom_min:float=2.0
@export var zoom_max:float=100.0

func _ready() -> void:
	var zoom_start_clamp:float=clampf(ZOOM_START,zoom_min,zoom_max)
	zoom_distance=zoom_start_clamp
	zoom_target=zoom_start_clamp
	camera.position.z=zoom_start_clamp
	CAMERA_MIN_ANGLE = deg_to_rad(CAMERA_MIN_ANGLE_DEG)
	CAMERA_MAX_ANGLE = deg_to_rad(CAMERA_MAX_ANGLE_DEG)
	CAMERA_ROTATION_SPEED=CAMERA_ROTATION_SPEED_CONFIG/1000
	inner_gimbal.rotation.x=deg_to_rad(clampf(CAMERA_START_ANGLE,CAMERA_MIN_ANGLE_DEG,CAMERA_MAX_ANGLE_DEG))

func _process(delta: float) -> void:

	var input_dir := Input.get_vector("camera_left", "camera_right", "camera_forward", "camera_back")
	var velocity:Vector3

	if Input.is_action_just_pressed("camera_up"):
		zoom_target+=ZOOM_STEP
	if Input.is_action_just_pressed("camera_down"):
		zoom_target+=-ZOOM_STEP
	_handle_zoom(delta)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * CAMERA_SPEED
		velocity.z = direction.z * CAMERA_SPEED



	global_position+=velocity*delta
	if x_rotation_pending !=0.0:
		_rotate_inner_gimbal()
	if y_rotation_pending !=0.0:
		_rotate_outer_gimbal()


func _handle_zoom(delta:float)->void:


	zoom_target=clampf(zoom_target,zoom_min,zoom_max)
	zoom_distance = lerp(zoom_distance, zoom_target, CAMERA_SCROLL_SPEED * delta)
	camera.position.z=zoom_distance


func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseMotion:
		var mouse_event:InputEventMouseMotion = event as InputEventMouseMotion
		if Input.is_action_pressed("camera_rotate"):
			var relative:Vector2 = mouse_event.relative
			x_rotation_pending+=-relative.y
			y_rotation_pending+=-relative.x



func _rotate_outer_gimbal()->void:
	rotate_y(y_rotation_pending*CAMERA_ROTATION_SPEED)
	y_rotation_pending=0

func _rotate_inner_gimbal()->void:
	var angle:float=inner_gimbal.rotation.x
	var to_turn:float=x_rotation_pending*CAMERA_ROTATION_SPEED
	var new_angle :float= clampf(angle + to_turn, CAMERA_MIN_ANGLE, CAMERA_MAX_ANGLE)
	inner_gimbal.rotation.x=new_angle
	x_rotation_pending=0
