extends Node

@onready var raycast_manager:RaycastManager=$RaycastManager
@onready var cube_manager:CubeManager=$CubeManager


var position:Vector3
var cube:Cube

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	raycast_manager.world_position_clicked.connect(_on_world_position_clicked)
	cube_manager.cube_clicked.connect(_on_cube_clicked)


func _on_world_position_clicked(position_clicked:Vector3)->void:
	#Todo Placeholder
	position=position_clicked
	cube=null
	print(position)

func _on_cube_clicked(cube_clicked:Cube)->void:
	cube=cube_clicked
	position=Vector3.ZERO
	print(cube)
