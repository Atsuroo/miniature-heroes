class_name CubeSpawner
extends Node

var cube_body:PackedScene=preload("res://scenes/cube.tscn")
signal cube_spawned(cube:Cube)



func spawn_cubes(amount:int)->void:

	for n in amount:
		var cube_instance:Cube=cube_body.instantiate()
		cube_instance.id=n
		var x_position:int=(n+1)*2

		add_child(cube_instance)
		cube_instance.global_position= Vector3(x_position,0,0)
		cube_spawned.emit(cube_instance)
