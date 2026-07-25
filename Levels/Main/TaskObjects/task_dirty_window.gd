extends TaskObjectBase
class_name DirtyWindowTask

@export var color_start: Color
@export var color_end: Color

@onready var mesh_instance: MeshInstance3D = $StaticBody3D/MeshInstance3D

func _ready():
	_update_color()

func _update_color() -> void:
	var new_color: Color = lerp(color_start, color_end, interact_level_current)
	mesh_instance.get_active_material(0).albedo_color = new_color

func _perform_action() -> void:
	_update_color()
	
func _undo_action() -> void:
	_update_color()


func _on_task_completed(task_object):
	$TaskCooldownTimer.start(randf_range(60, 90))


func _on_task_cooldown_timer_timeout():
	_reset_task()
	_update_color()
