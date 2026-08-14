extends MeshInstance3D
class_name HexagonMesh

@export var label_x:Label3D
@export var label_y:Label3D
@export var label_z:Label3D

@export var border:MeshInstance3D
@export var border_hover:MeshInstance3D
@export var border_select:MeshInstance3D

var text_offset:float=0.1

func set_axes_text(x:int,y:int,z:int,tile_height:float)->void:
	#the top is only half height from the center so /2
	var height:float=tile_height/2+text_offset

	label_x.text=str("X: ",x)
	label_x.position.y=height

	label_y.text=str("Y: ",y)
	label_y.position.y=height

	label_z.text=str("z: ",z)
	label_z.position.y=height
