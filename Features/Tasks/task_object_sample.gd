extends TaskObjectBase
class_name TaskObjectSample

@export var color_start: Color
@export var color_end: Color

@onready var mesh_instance: MeshInstance3D = $StaticBody3D/MeshInstance3D

func _perform_action() -> void:
	var new_color: Color = lerp(color_start, color_end, interact_level_current)
	mesh_instance.get_active_material(0).albedo_color = new_color
