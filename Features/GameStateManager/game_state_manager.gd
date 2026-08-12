class_name GameStateManager
extends Node

enum GameState {
	NONE,
	INTRO,
	COUNT_RESTING,
	COUNT_PATROLLING,
	COUNT_RETURNING
}


@export_category("References")
## Specifies the container Node containing Tasks to track
@export var _player: Player = null
@export var _player_spawn_point: Node3D = null
@export var _task_manager : TaskManager = null
@export var _hud: HUD = null
@export var _screen: Screen = null
@export var _count_ai : CharacterBody3D = null

@export_category("Game Mode")
@export var night_duration_in_seconds : float = 120
@export var objectives_display_time_in_seconds : float = 2.0
@export var intro_screen_display_time_in_seconds : float = 2.0
@export var end_screen_display_time_in_seconds : float = 2.0
@export var game_over_screen_display_time_in_seconds : float = 2.0

# Get references to the timers.
@onready var player_freeze_timer: Timer = $PlayerFreezeTimer
@onready var intro_screen_timer: Timer = $IntroScreenTimer
@onready var day_complete_screen_timer: Timer = $DayCompleteScreenTimer
@onready var game_over_screen_timer: Timer = $GameOverScreenTimer
@onready var _count_patrol_countdown : Timer = $CountPatrolCountdown


var nights_completed: int = 0
var _debug_mode = true

var _game_state : GameState = GameState.NONE


#-------------------------------------------------------------------------------
func _ready() -> void:
	
	# Set timer durations based on game config.
	player_freeze_timer.wait_time = objectives_display_time_in_seconds
	intro_screen_timer.wait_time = intro_screen_display_time_in_seconds
	day_complete_screen_timer.wait_time = end_screen_display_time_in_seconds
	game_over_screen_timer.wait_time = intro_screen_display_time_in_seconds
	
	_player.hud = _hud
	
	# Sets the state to intro and kicks off a new day.
	_set_game_state(GameState.INTRO)


#-------------------------------------------------------------------------------
func _on_intro_screen_timer_timeout():
	_start_round()
	
	
#-------------------------------------------------------------------------------
func _on_day_complete_screen_timer_timeout():
	_start_new_day()


#-------------------------------------------------------------------------------
func _on_task_manager_all_tasks_completed() -> void:
	_show_end_screen()


#-------------------------------------------------------------------------------
func _on_player_freeze_timer_timeout():
	_player.is_frozen = false
	_hud.objectives_list.visible = false
	_count_patrol_countdown.start(night_duration_in_seconds)


#-------------------------------------------------------------------------------
func _game_over():
	_hud.night_timer.dayTimer.stop()
	_player.is_frozen = true
	_screen.visible = true
	_screen.label.text = "After %d nights, you shift is forever over." % nights_completed
	game_over_screen_timer.start()


#-------------------------------------------------------------------------------
func _on_game_over_screen_timer_timeout():
	get_tree().change_scene_to_file("res://screens/main_menu.tscn")


#-------------------------------------------------------------------------------
func _on_count_patrol_countdown_timeout() -> void:
	_game_over()


#-------------------------------------------------------------------------------
func _process(_delta: float) -> void:
	if not _count_patrol_countdown.is_stopped():
		_hud.set_countdown_timer_display(_count_patrol_countdown.time_left)
	
	
	if _debug_mode:
		if Input.is_action_just_pressed("debug_reset_ai"):
			_count_ai.reset()
		if Input.is_action_just_pressed("debug_bright_light"):
			var env : Environment = $WorldEnvironment.environment
			env.background_energy_multiplier = 2
			$WorldEnvironment.environment = env



#-------------------------------------------------------------------------------
func _set_game_state(new_state : GameState) -> void:
	_game_state = new_state
	
	match new_state:
		GameState.INTRO:
			_start_new_day()


#-------------------------------------------------------------------------------
func _start_new_day():
	_player.transform = _player_spawn_point.transform
	_player.is_frozen = true
	intro_screen_timer.start()
	_screen.visible = true
	nights_completed += 1
	_screen.label.text = "Night %d" % nights_completed


#-------------------------------------------------------------------------------
func _start_round():
	
	_task_manager.reset_task_states()
	
	_hud.set_countdown_timer_display(night_duration_in_seconds)
	_screen.visible = false
	
	_hud.objectives_list.visible = true
	_player.is_frozen = true
	player_freeze_timer.start()

	
#-------------------------------------------------------------------------------
func _show_end_screen():
	_count_patrol_countdown.stop()
	_player.is_frozen = true
	_screen.visible = true
	_screen.label.text = "Night Survived"
	day_complete_screen_timer.start()
	_count_ai.reset()
	

#-------------------------------------------------------------------------------
