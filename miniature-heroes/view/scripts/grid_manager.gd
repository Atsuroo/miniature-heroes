extends Node

@export var settings:HexSettingsType
@onready var grid_visual_manager:GridVisualManager=$GridVisualManager
@onready var grid_hex_manager:GridHexCoordManager=$GridHexCoordManager



func _ready() -> void:
	var axial_coords:Array[Vector2i] =grid_hex_manager._initialise_grid()
	grid_visual_manager.settings=settings
	grid_visual_manager.build_Grid(axial_coords)
