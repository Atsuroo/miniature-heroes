extends Node

@onready var grid_manager:GridManager=$GridManager
@onready var raycast_manager:RaycastManager=$RaycastManager

var visual_change_pending:bool=false
var visual_highlights:VisualHighlights=VisualHighlights.new()

func _ready() -> void:
	raycast_manager.world_position_clicked.connect(_on_world_position_clicked)
	raycast_manager.hover_tile_position.connect(_on_hover_tile_position)
	raycast_manager.hover_tile_leave.connect(_on_hover_tile_leave)


func _process(_delta: float) -> void:
	if visual_change_pending:
		grid_manager.apply_visual_change(visual_highlights)
		visual_change_pending=false

func _on_world_position_clicked(world_positon:Vector3)->void:
	var tile :=grid_manager.get_tile_from_world_position(world_positon)
	visual_highlights.is_tile_selected=true
	visual_highlights.selected_tile=tile
	visual_change_pending=true


func _on_hover_tile_position(position_hovered:Vector3)->void:

	var tile :=grid_manager.get_tile_from_world_position(position_hovered)
	if visual_highlights.hovered_tile != tile || visual_highlights.is_tile_hovered ==false:
		_hover_tile_enter(tile)


func _hover_tile_enter(tile:Vector2i)->void:
	visual_highlights.is_tile_hovered=true
	visual_highlights.hovered_tile=tile
	visual_change_pending=true

func _on_hover_tile_leave()->void:
	if visual_highlights.is_tile_hovered==true:
		_hover_tile_leave()

func _hover_tile_leave()->void:
	visual_highlights.is_tile_hovered=false
	visual_change_pending=true
