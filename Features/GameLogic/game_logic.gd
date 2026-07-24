extends Node

var player: Player
var task_objects: Array[TaskObjectBase]
	
func register_player(in_player: Player) -> void:
	player = in_player
	
# These might well just be sequential, we will have to see
func register_task(task_object: TaskObjectBase):
	task_object.on_task_updated.connect(_on_task_updated)
	task_object.on_task_completed.connect(_on_task_completed)
	task_objects.append(task_object)
	
func _on_task_updated(task_object: TaskObjectBase, interact_level_current: float, interact_level_end: float):
	player.hud.set_task_meter(interact_level_current, interact_level_end)
	
func _on_task_completed(task_object: TaskObjectBase):
	player.hud.show_task_complete()
