class_name CubeManager
extends Node

@export var cube_amount:int=1
@onready var cube_spawner:CubeSpawner = $CubeSpawner
@onready var cube_selector:CubeSelector = $CubeSelector

signal cube_clicked(cube:Cube)

func _ready() -> void:
	cube_spawner.cube_spawned.connect(_on_cube_spawned)
	cube_spawner.spawn_cubes(cube_amount)


func _on_cube_spawned(cube:Cube)->void:
	cube.clicked.connect(_on_cube_clicked)

func _on_cube_clicked(who:Cube)->void:
	print("Cube nr "+str(who.id))
	cube_selector.cube_selected(who)
	cube_clicked.emit(who)
