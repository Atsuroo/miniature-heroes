extends Node
class_name GridHexCoordManager

var axial_coords : Array[Vector2i]
@export var size:int=1

func _initialise_grid()->Array[Vector2i]:
	axial_coords.append_array(Hex.spiral(Vector2i(0,0),size))
	return axial_coords
