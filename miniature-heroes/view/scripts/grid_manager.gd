extends Node
class_name GridManager

@export var hex_settings:HexSettingsType
@export var board_settings:BoardSettingsType
@onready var grid_visual_manager:GridVisualManager=$GridVisualManager

var axial_coords:Array[Vector2i]=[]


func _ready() -> void:
	axial_coords=_initialise_grid()
	grid_visual_manager.settings=hex_settings
	grid_visual_manager.build_Grid(axial_coords)

func apply_visual_change(visual:VisualHighlights)->void:
	grid_visual_manager.apply_visual_change(visual)

func get_tile_from_world_position(world:Vector3)->Vector2i:
	var axial:Vector2i=HexWorld.world_to_axial(world,hex_settings.hex_size)
	return axial


func _initialise_grid()->Array[Vector2i]:
	axial_coords.append_array(Hex.spiral(Vector2i(0,0),board_settings.board_size))
	return axial_coords
