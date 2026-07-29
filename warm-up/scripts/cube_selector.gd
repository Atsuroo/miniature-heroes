class_name CubeSelector
extends Node
var selected:Cube

func cube_selected(cube:Cube=null)->void:

	if selected:
		selected.set_highlighted(false)

	if cube:
		cube.set_highlighted(true)

	selected=cube
