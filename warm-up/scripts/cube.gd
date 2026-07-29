class_name Cube
extends RigidBody3D

@onready var mesh_instance:MeshInstance3D=$MeshInstance3D
@export var highlight_material:StandardMaterial3D

var id:int
signal clicked(who:Cube)

func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
			clicked.emit(self)

func _change_surface_material(material:StandardMaterial3D)->void:
	mesh_instance.set_surface_override_material(0,material)

func set_highlighted(highlighted:bool)->void:
	if highlighted:
		_change_surface_material(highlight_material)
	else:
		_change_surface_material(null)
