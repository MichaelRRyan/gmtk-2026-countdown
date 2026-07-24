extends Node3D
class_name TaskObjectBase

signal on_task_completed(task_object: TaskObjectBase)
signal on_task_updated(task_object: TaskObjectBase, interact_level_current: float, interact_level_end: float)

@export var interact_increase_rate: float = 0.1
@export var interact_level_start: float = 0.0
@export var interact_level_end: float = 100.0

var interact_level_current: float = 0.0
var task_complete: bool = false

func _ready() -> void:
	GameLogic.register_task(self)
	interact_level_current = interact_level_start

func interact_hold(delta: float) -> void:
	if task_complete:
		return

	if interact_level_current >= interact_level_end:
		task_complete = true
		on_task_completed.emit(self)
		return
	
	interact_level_current += (interact_increase_rate * delta)
	on_task_updated.emit(self, interact_level_current, interact_level_end)
	
	_perform_action()
	
func _perform_action() -> void:
	pass
