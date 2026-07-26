extends Node
class_name GameLogic

@export var task_container : Node = self

@export_category("Game Mode")
@export var number_of_tasks_available_per_round = 8
@export var tasks_to_complete_per_round = 1
@export var objectives_display_time_in_seconds = 2.0
@export var intro_screen_display_time_in_seconds = 2.0
@export var end_screen_display_time_in_seconds = 2.0
@export var game_over_screen_display_time_in_seconds = 2.0

@onready var player: Player = $Player
@onready var hud: HUD = $HUD
@onready var screen: Screen = $Screen
@onready var player_freeze_timer: Timer = $Timers/PlayerFreezeTimer
@onready var intro_screen_timer: Timer = $Timers/IntroScreenTimer
@onready var end_screen_timer: Timer = $Timers/EndScreenTimer
@onready var game_over_screen_timer: Timer = $Timers/GameOverScreenTimer
@onready var player_spawn_point: Node3D = $PlayerSpawnPoint

var task_objects: Array[TaskObjectBase]
	
var tasks_completed: int = 0
var nights_completed: int = 0
	
func _ready() -> void:
	player_freeze_timer.wait_time = objectives_display_time_in_seconds
	intro_screen_timer.wait_time = intro_screen_display_time_in_seconds
	end_screen_timer.wait_time = end_screen_display_time_in_seconds
	game_over_screen_timer.wait_time = intro_screen_display_time_in_seconds
	player_freeze_timer.timeout.connect(_on_player_freeze_timeout)
	intro_screen_timer.timeout.connect(_on_intro_screen_timeout)
	end_screen_timer.timeout.connect(_on_end_screen_timeout)
	game_over_screen_timer.timeout.connect(_on_game_over_screen_timeout)
	player.hud = hud
	for child in task_container.get_children(true):
		if child is Interactable:
			child.hud = hud
			if child is TaskObjectBase:
				var task_object: TaskObjectBase = child as TaskObjectBase
				register_task(task_object)	
	
	_prepare_round()

func _prepare_round():
	player.position = player_spawn_point.position
	player.rotation = player_spawn_point.rotation
	player.is_frozen = true
	screen.visible = true
	nights_completed += 1
	screen.label.text = "Night %d" % nights_completed
	intro_screen_timer.start()
	
func _on_intro_screen_timeout():
	_start_round()
	
func _on_end_screen_timeout():
	_prepare_round()
	
func _on_game_over_screen_timeout():
	pass

func _start_round():
	for task_object in task_objects:
		task_object.set_hidden()
	
	screen.visible = false
	tasks_completed = 0
	hud.objectives_list.reset()
	hud.objectives_list.set_tasks_left(tasks_to_complete_per_round - tasks_completed)
	var tasks_to_activate = select_number_of_tasks(number_of_tasks_available_per_round)
	for task in tasks_to_activate:
		task.initialize_task()
		hud.objectives_list.set_task_objective(task)
	
	hud.objectives_list.visible = true
	player.is_frozen = true
	player_freeze_timer.start()
	
func _on_player_freeze_timeout():
	player.is_frozen = false
	hud.objectives_list.visible = false
	
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
	tasks_completed += 1
	if tasks_completed == tasks_to_complete_per_round:
		_show_end_screen()
		return
		
	hud.show_task_complete()
	hud.objectives_list.remove_task_objective(task_object)
	hud.objectives_list.set_tasks_left(tasks_to_complete_per_round - tasks_completed)
	if task_object.consume_item_on_completion:
		player.holdable_item_manager.destroy_current_item()


func _on_task_reset(task_object: TaskObjectBase):
	hud.objectives_list.set_task_objective(task_object)
	hud.show_new_task(task_object)


func on_can_interact(can_interact: bool):
	hud.set_crosshair_interactable(can_interact)

	
func _show_end_screen():
	player.is_frozen = true
	screen.visible = true
	screen.label.text = "Night Survived"
	end_screen_timer.start()
	
