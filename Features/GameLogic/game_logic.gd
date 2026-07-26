extends Node

@export var task_container : Node = self

@export_category("Game Mode")
@export var number_of_tasks_per_round = 5
@export var objectives_display_time = 2

@onready var player: Player = $Player
@onready var hud: HUD = $HUD
@onready var player_freeze_timer: Timer = $PlayerFreezeTimer

var task_objects: Array[TaskObjectBase]
	
func _ready() -> void:
	player_freeze_timer.wait_time = objectives_display_time
	player_freeze_timer.timeout.connect(_on_player_freeze_timeout)
	
	player.hud = hud
	for child in task_container.get_children(true):
		if child is Interactable:
			child.hud = hud
			if child is TaskObjectBase:
				var task_object: TaskObjectBase = child as TaskObjectBase
				register_task(task_object)	
				
	_start_round()

func _start_round():
	var tasks_to_activate = select_number_of_tasks(number_of_tasks_per_round)
	for task in tasks_to_activate:
		task.initialize_task()
		hud.objectives_list.set_task_objective(task)
	
	hud.objectives_list.visible = true
	player.is_frozen = true
	player_freeze_timer.start()
	
func _on_player_freeze_timeout():
	player.is_frozen = false
	hud.objectives_list.visible = false
	# This is where the timer will get kicked off
	
func select_number_of_tasks(number_of_tasks: int):
	var eligible_tasks = task_objects.duplicate()
	for eligible_task in eligible_tasks:
		if eligible_task.is_task_complete:
			eligible_tasks.erase(eligible_task)
	
	var tasks = Array()
	for n in range(number_of_tasks):
		var eligible_task: TaskObjectBase = eligible_tasks.pick_random()
		tasks.append(eligible_task)
		eligible_tasks.erase(eligible_task)
	
	return tasks

func register_task(task_object: TaskObjectBase):
	task_object.on_task_updated.connect(_on_task_updated)
	task_object.on_task_completed.connect(_on_task_completed)
	task_object.on_task_reset.connect(_on_task_reset)
	task_object.set_hidden()
	#hud.objectives_list.set_task_objective(task_object)
	task_objects.append(task_object)
	
	
func _on_task_updated(task_object: TaskObjectBase, interact_level_current: float, interact_level_end: float):
	if task_object == player.last_interacted_object:
		hud.set_task_meter(interact_level_current, interact_level_end)
	
	
func _on_task_completed(task_object: TaskObjectBase):
	hud.show_task_complete()
	hud.objectives_list.remove_task_objective(task_object)
	if task_object.consume_item_on_completion:
		player.holdable_item_manager.destroy_current_item()


func _on_task_reset(task_object: TaskObjectBase):
	hud.objectives_list.set_task_objective(task_object)
	hud.show_new_task(task_object)


func on_can_interact(can_interact: bool):
	hud.set_crosshair_interactable(can_interact)
