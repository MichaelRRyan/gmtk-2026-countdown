extends Node3D
class_name TaskObjectBase

signal on_task_completed(task_object: TaskObjectBase)
signal on_task_updated(task_object: TaskObjectBase, interact_level_current: float, interact_level_end: float)

@export_category("Completion Rates")
@export var interact_increase_rate: float = 0.1
@export var interact_delay_before_decrease: float = 0.05
@export var interact_decrease_rate: float = 0.05
@export var interact_level_start: float = 0.0
@export var interact_level_end: float = 100.0

@export_category("Display")
@export var objective_text: String = "DEBUG"

@export_category("Config")
@export var is_active: bool = true

var is_increasing: bool = false
var interact_level_current: float = interact_level_start
var is_task_complete: bool = false
	
func _process(delta: float) -> void:
	if not is_active or is_task_complete or is_increasing or interact_level_current <= 0:
		return
		
	interact_level_current -= (interact_decrease_rate * delta)
	on_task_updated.emit(self, interact_level_current, interact_level_end)
	_undo_action()

func interact_hold(delta: float) -> void:
	if is_task_complete or not is_active:
		return

	if interact_level_current >= interact_level_end:
		is_task_complete = true
		on_task_completed.emit(self)
		return
	
	is_increasing = true
	interact_level_current += (interact_increase_rate * delta)
	on_task_updated.emit(self, interact_level_current, interact_level_end)
	
	_perform_action()
	
func interact_release(delta: float) -> void:
	is_increasing = false	
	
func _perform_action() -> void:
	pass
	
func _undo_action() -> void:
	pass
