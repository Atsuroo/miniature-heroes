extends Node
class_name GridVisualManager

@export var grid_mesh:PackedScene

@export var mesh: CylinderMesh
@export var border_mesh: CylinderMesh
@export var selected_border:CylinderMesh
@export var hover_border:CylinderMesh

@export var tile_cylinder_shape: CylinderShape3D

var tiles:Dictionary[Vector2i,HexagonMesh]
var settings:HexSettingsType



const HOVER_BORDER_OFFSET:float=0.01
const SELECT_BORDER_OFFSET:float=0.02



func scale_tiles()->void:

	mesh.top_radius = settings.hex_size-(settings.hex_size*settings.border_thickness_scaling)
	mesh.bottom_radius = settings.hex_size
	mesh.height = settings.tile_height

	selected_border.top_radius = settings.hex_size
	selected_border.bottom_radius = settings.hex_size
	selected_border.height = settings.tile_height-(settings.tile_height*settings.border_height_scaling)+SELECT_BORDER_OFFSET

	hover_border.top_radius = settings.hex_size
	hover_border.bottom_radius = settings.hex_size
	hover_border.height = settings.tile_height-(settings.tile_height*settings.border_height_scaling)+HOVER_BORDER_OFFSET

	border_mesh.top_radius = settings.hex_size
	border_mesh.bottom_radius = settings.hex_size
	border_mesh.height = settings.tile_height-(settings.tile_height*settings.border_height_scaling)

	tile_cylinder_shape.radius = settings.hex_size
	tile_cylinder_shape.height = settings.tile_height



func build_Grid(axial_positions:Array[Vector2i])->void:
	for axial in axial_positions:
		var instance:HexagonMesh=grid_mesh.instantiate()
		add_child(instance)

		var cube:Vector3i=Hex.to_cube(axial)
		instance.set_axes_text(cube.x,cube.y,cube.z,settings.tile_height)

		instance.global_position=HexWorld.axial_to_world(axial,settings.hex_size)
		tiles.set(axial,instance)

	scale_tiles()


func apply_visual_change(visual:VisualHighlights)->void:
	for tile in tiles:
		var hex:HexagonMesh=tiles.get(tile)
		hex.border_select.visible=visual.is_tile_selected and tile ==visual.selected_tile
		hex.border_hover.visible=visual.is_tile_hovered and tile ==visual.hovered_tile
