extends Node
class_name GridVisualManager

@export var grid_mesh:PackedScene

@export var mesh: CylinderMesh
@export var border_mesh: CylinderMesh

var tiles:Dictionary[Vector2i,MeshInstance3D]
var settings:HexSettingsType


func scale_tiles()->void:

	mesh.top_radius = settings.hex_size-(settings.hex_size*settings.border_thickness_scaling)
	mesh.bottom_radius = settings.hex_size
	mesh.height = settings.tile_height

	border_mesh.top_radius = settings.hex_size
	border_mesh.bottom_radius = settings.hex_size
	border_mesh.height = settings.tile_height-(settings.tile_height*settings.border_height_scaling)



func build_Grid(axial_positions:Array[Vector2i])->void:
	for axial in axial_positions:
		var instance:HexagonMesh=grid_mesh.instantiate()
		add_child(instance)

		var cube:Vector3i=Hex.to_cube(axial)
		instance.set_axes_text(cube.x,cube.y,cube.z,settings.tile_height)

		instance.global_position=HexWorld.axial_to_world(axial,settings.hex_size)
		tiles.set(axial,instance)

	scale_tiles()
