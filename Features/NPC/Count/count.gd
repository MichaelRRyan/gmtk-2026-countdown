extends CharacterBody3D

signal returned_to_rest
signal caught_player

enum BehaviourState {
	NONE,
	REST,
	RETURN, # Make their way back to resting place.
	WANDER,
	CHASE,
	SEARCH,
}

@export var min_wander_time_secs : float = 40.0
@export var max_wander_time_secs : float = 60.0
@export var search_time_secs : float = 10.0
@export var search_radius : float = 5.0

@onready var _nav = $NavigationAgent3D
@onready var _raycast = $RayCast3D
@onready var _search_timer = $SearchTimer
@onready var _patrol_timer = $PatrolTimer
@onready var _viewcone = $Viewcone
@onready var _animated_mesh = $Vampire
@onready var _footstep_audio = $FootstepAudio
@onready var _wander_timer = $WanderTimer

var _state : BehaviourState = BehaviourState.NONE
var speed : float = 2.5
var gravity : float = 9.8
var _next_nav_location : Vector3 = Vector3.ZERO
var _last_known_player_location : Vector3 = Vector3.ZERO
var _player : Player = null
var _start_transform : Transform3D = Transform3D.IDENTITY

var _debug_print : bool = true


#-------------------------------------------------------------------------------
## Resets the vampire to its starting position and puts it back into REST.
func reset() -> void:
	_debug("Resetting")
	
	global_transform = _start_transform
	set_state(BehaviourState.REST)


#-------------------------------------------------------------------------------
## Starts the vampire's normal wandering behaviour.
func start_wandering() -> void:
	set_state(BehaviourState.WANDER)


#-------------------------------------------------------------------------------
## Changes state and handles the old and new state's entry/exit behaviour.
func set_state(new_state : BehaviourState) -> void:
	if _state != new_state:
		_exit_state(_state)
		_state = new_state
		_enter_state(_state)


#-------------------------------------------------------------------------------
## Performs any setup required when entering a new behaviour state.
func _enter_state(state : BehaviourState) -> void:
	match state:
		BehaviourState.REST:
			velocity = Vector3.ZERO
			_viewcone.monitoring = false
			visible = false
			returned_to_rest.emit()
			_debug("Resting")
		
		BehaviourState.RETURN:
			_nav.target_position = _start_transform.origin
			_debug("Returning")
		
		BehaviourState.WANDER:
			if _wander_timer.paused:
				_wander_timer.paused = false
				_debug("Wandering - Resumed")
			else:
				_wander_timer.start(randf_range(min_wander_time_secs, max_wander_time_secs))
				_debug("Wandering")
		
		BehaviourState.CHASE:
			_wander_timer.paused = true
			_debug("Chasing")
		
		BehaviourState.SEARCH:
			_search_timer.start(search_time_secs)
			_set_next_search_location()
			_debug("Searching")


#-------------------------------------------------------------------------------
## Performs any cleanup required when leaving the current behaviour state.
func _exit_state(state : BehaviourState) -> void:
	match state:
		BehaviourState.REST:
			_viewcone.monitoring = true
			visible = true
		
		BehaviourState.WANDER:
			_wander_timer.paused = true
		
		BehaviourState.SEARCH:
			_search_timer.stop()


#-------------------------------------------------------------------------------
## Stores the starting transform and initializes the vampire in REST.
func _ready() -> void:
	_start_transform = global_transform
	_find_next_nav_location()
	_animated_mesh.set_state_idle()
	set_state(BehaviourState.REST)


#-------------------------------------------------------------------------------
## Processes physics, the current behaviour state, movement and animation.
func _process(delta: float) -> void:
	_process_gravity(delta)
	_process_state()
	move_and_slide()
	_process_movement_feedback()


#-------------------------------------------------------------------------------
## Applies gravity while the vampire is airborne.
func _process_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y -= 2


#-------------------------------------------------------------------------------
## Processes the behaviour associated with the current state.
func _process_state() -> void:
	match _state:
		BehaviourState.REST:
			pass
		
		BehaviourState.RETURN:
			_process_return()
		
		BehaviourState.WANDER:
			_process_wander()
		
		BehaviourState.CHASE:
			_process_chase()
		
		BehaviourState.SEARCH:
			_process_search()


#-------------------------------------------------------------------------------
## Returns the vampire to its starting position before entering REST.
func _process_return() -> void:
	if _nav.is_target_reached():
		set_state(BehaviourState.REST)
	else:
		_nav.target_position = _start_transform.origin
		_move_along_path()


#-------------------------------------------------------------------------------
## Moves between random locations while checking for the player.
func _process_wander() -> void:
	if _player and _check_player_line_of_sight():
		set_state(BehaviourState.CHASE)
	else:
		if _nav.is_navigation_finished():
			_find_next_nav_location()
			_patrol_timer.start()
		
		_nav.target_position = _next_nav_location
		_move_along_path()


#-------------------------------------------------------------------------------
## Chases the player while they remain in direct line of sight.
func _process_chase() -> void:
	if _player and _check_player_line_of_sight():
		_last_known_player_location = _player.global_position
		_nav.target_position = _player.global_position
		_move_along_path()
	else:
		if _player:
			_last_known_player_location = _player.global_position
		
		set_state(BehaviourState.SEARCH)


#-------------------------------------------------------------------------------
## Searches around the player's last known location until the search expires.
func _process_search() -> void:
	if _player and _check_player_line_of_sight():
		set_state(BehaviourState.CHASE)
	else:
		if _nav.is_navigation_finished():
			_set_next_search_location()
		
		_move_along_path()


#-------------------------------------------------------------------------------
## Checks whether the player can currently be seen by the vampire.
func _check_player_line_of_sight() -> bool:
	var player_visible : bool = false
	
	if _player:
		_raycast.target_position = to_local(_player.global_position)
		_raycast.force_raycast_update()
		
		if _raycast.is_colliding() and _raycast.get_collider() == _player:
			player_visible = true
			_last_known_player_location = _player.global_position
	
	return player_visible


#-------------------------------------------------------------------------------
## Chooses a random navigation point within the search radius of the last known location.
func _set_next_search_location() -> void:
	var random_offset = Vector2.from_angle(randf() * TAU) * randf_range(0.0, search_radius)
	_next_nav_location = _last_known_player_location + Vector3(random_offset.x, 0, random_offset.y)
	_nav.target_position = _next_nav_location


#-------------------------------------------------------------------------------
## Chooses a new random location within the vampire's normal wandering area.
func _find_next_nav_location() -> void:
	var start_pos = global_transform.origin
	var random_x = randi_range(-10, 10)
	var random_z = randi_range(-10, 10)
	_next_nav_location = Vector3(start_pos.x + random_x, start_pos.y, start_pos.z + random_z)


#-------------------------------------------------------------------------------
## Moves the vampire towards the next navigation path position.
func _move_along_path() -> void:
	var next_location = _nav.get_next_path_position()
	
	if next_location != global_transform.origin:
		look_at(next_location, Vector3(0, 1, 0))
		rotation.x = 0
		rotation.z = 0
	
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * speed
	velocity = velocity.move_toward(new_velocity, 0.25)


#-------------------------------------------------------------------------------
## Updates walking animation and footstep audio based on horizontal movement.
func _process_movement_feedback() -> void:
	var horizontal_velocity = Vector2(velocity.x, velocity.z)
	
	if horizontal_velocity.length_squared() > 0:
		_footstep_audio.play()
		_animated_mesh.set_state_walking()
	else:
		_footstep_audio.stop()
		_animated_mesh.set_state_idle()


#-------------------------------------------------------------------------------
## Handles the patrol timer based on the current movement state.
func _on_timer_timeout() -> void:
	if _state == BehaviourState.WANDER:
		_find_next_nav_location()


#-------------------------------------------------------------------------------
## Ends the search and sends the vampire home when the search timer expires.
func _on_search_timer_timeout() -> void:
	if _state == BehaviourState.SEARCH:
		set_state(BehaviourState.WANDER)


#-------------------------------------------------------------------------------
## Records a player entering the view cone and begins chasing if visible.
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player = body
		
		if _state != BehaviourState.REST and _check_player_line_of_sight():
			set_state(BehaviourState.CHASE)


#-------------------------------------------------------------------------------
## Records a player leaving the view cone without interrupting an active chase.
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and body == _player:
		if _state == BehaviourState.CHASE:
			_last_known_player_location = body.global_position
		
		_player = null


#-------------------------------------------------------------------------------
## Emits the caught signal when the vampire collides with the player while chasing.
func _check_for_player_collision(body: Node3D) -> void:
	if _state == BehaviourState.CHASE and body.is_in_group("player"):
		caught_player.emit()


#-------------------------------------------------------------------------------
## Sends a wandering vampire home when its wandering period expires.
func _on_wander_timer_timeout() -> void:
	if _state == BehaviourState.WANDER:
		set_state(BehaviourState.RETURN)


#-------------------------------------------------------------------------------
## Prints a debug message when AI debugging is enabled.
func _debug(message : String) -> void:
	if _debug_print:
		print(message)


#-------------------------------------------------------------------------------
