class_name TaskManager
extends Node

signal all_tasks_completed


@export_category("References")
@export var _task_container : Node = self
@export var _return_to_bed_task : ReturnToBedTask = null
@export var _hud: HUD = null
@export var _player: Player = null

@export_category("Config")
@export var number_of_tasks_available_per_round = 6

var task_objects: Array[TaskObjectBase]
var _tasks_remaining : int = 0


#-------------------------------------------------------------------------------
func reset_task_states():
	for task_object in task_objects:
		task_object.set_hidden()

	_tasks_remaining = 0
	_hud.objectives_list.reset()
	
	var tasks_to_activate = _select_number_of_tasks(number_of_tasks_available_per_round)
	for task : TaskObjectBase in tasks_to_activate:
		task.initialize_task()
		_hud.objectives_list.set_task_objective(task)
	
	_hud.objectives_list.set_tasks_left(_tasks_remaining)
	
	_return_to_bed_task.set_hidden()


#-------------------------------------------------------------------------------
# PRIVATE INTERFACE
#-------------------------------------------------------------------------------
func _ready() -> void:
	for child in _task_container.get_children(true):
		if child is Interactable:
			child.hud = _hud
			if child is TaskObjectBase:
				var task_object: TaskObjectBase = child
				register_task(task_object)
	
	# Set up the return to bed signals.
	_return_to_bed_task.on_task_completed.connect(_on_task_completed)
	_return_to_bed_task.on_task_reset.connect(_on_task_reset)


#-------------------------------------------------------------------------------
func _select_number_of_tasks(number_of_tasks: int):
	var eligible_tasks = task_objects.duplicate()
	for eligible_task in eligible_tasks:
		if eligible_task.is_task_complete:
			eligible_tasks.erase(eligible_task)
	
	var tasks = Array()
	for n in range(number_of_tasks):
		
		if eligible_tasks.is_empty():
			break
			
		var eligible_task: TaskObjectBase = eligible_tasks.pick_random()
		tasks.append(eligible_task)
		eligible_tasks.erase(eligible_task)
		_tasks_remaining += 1
	
	return tasks


#-------------------------------------------------------------------------------
func register_task(task_object: TaskObjectBase):
	task_object.on_task_updated.connect(_on_task_updated)
	task_object.on_task_completed.connect(_on_task_completed)
	task_object.on_task_reset.connect(_on_task_reset)
	task_object.set_hidden()
	task_objects.append(task_object)


#-------------------------------------------------------------------------------
func _on_task_updated(task_object: TaskObjectBase, interact_level_current: float, interact_level_end: float):
	if task_object == _player._current_interactable:
		_hud.set_task_meter(interact_level_current, interact_level_end)
	
	
#-------------------------------------------------------------------------------
func _on_task_completed(task_object: TaskObjectBase):
	_tasks_remaining -= 1
	if _tasks_remaining <= 0:
		
		# Enable the Go To Bed task if not already complete.
		if not _return_to_bed_task.is_task_complete:
			_return_to_bed_task.is_active = true
			_hud.objectives_list.set_task_objective(_return_to_bed_task)
			_hud.show_new_task(_return_to_bed_task)
			
		else:
			all_tasks_completed.emit()
			return
		
	_hud.show_task_complete()
	_hud.objectives_list.remove_task_objective(task_object)
	_hud.objectives_list.set_tasks_left(_tasks_remaining)
	if task_object.consume_item_on_completion:
		_player.holdable_item_manager.destroy_current_item()


#-------------------------------------------------------------------------------
# If a task is reset (needs to be done again).
func _on_task_reset(task_object: TaskObjectBase):
	_hud.objectives_list.set_task_objective(task_object)
	_hud.show_new_task(task_object)
	_tasks_remaining += 1
	
	# If the return to bed task is active, remove it from the objective list
	if task_object != _return_to_bed_task and _return_to_bed_task.is_active:
		_hud.objectives_list.remove_task_objective(_return_to_bed_task)
		_return_to_bed_task.set_hidden()


#-------------------------------------------------------------------------------
