extends CharacterBody3D

enum BehaviourState {
	NONE,
	REST,
	RETURN, # Make their way back to resting place.
	WANDER,
	CHASE,
	SEARCH,
}

@onready var nav = $NavigationAgent3D
@onready var raycast = $RayCast3D
@onready var _player_memory_timer = $MemoryTimer
@onready var patrol_timer = $PatrolTimer
@onready var _animated_mesh = $Vampire

var _state : BehaviourState = BehaviourState.REST
var speed : float = 2.5
var gravity : float = 9.8
var next_nav_location : Vector3 = Vector3.ZERO
var player_found : bool = false
var player : Player = null
var _start_transform : Transform3D = Transform3D.IDENTITY
var _start_position : Vector3 = Vector3.ZERO



#-------------------------------------------------------------------------------
func reset() -> void:
	global_transform = _start_transform
	set_state(BehaviourState.REST)
	$StartIdleTimer.start()


#-------------------------------------------------------------------------------
func set_state(new_state : BehaviourState) -> void:
	
	# Enable/disable the viewcone depending on whether we're in the rest state.
	if _state == BehaviourState.REST:
		$Viewcone.monitoring = true
	
	if new_state == BehaviourState.REST:
		$Viewcone.monitoring = false
		velocity = Vector3.ZERO
	
	_state = new_state
	print("New State: " + str(_state))


#-------------------------------------------------------------------------------
func _ready() -> void:
	_start_transform = global_transform
	find_next_nav_location()
	_animated_mesh.set_state_idle()


#-------------------------------------------------------------------------------
func _process(delta: float) -> void:
	# Apply gravity if not on the ground.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y -= 2
	
	# Process whichever state we're in.
	match _state:
		BehaviourState.WANDER:
			_process_wander()
		BehaviourState.CHASE:
			_process_chase()
	
	move_and_slide()
	
	# Set the animation and footstep audio states.
	var horizontal_vel = Vector2(velocity.x, velocity.z)
	if horizontal_vel.length_squared() > 0:
		$FootstepAudio.play()
		_animated_mesh.set_state_walking()
	else:
		$FootstepAudio.stop()
		_animated_mesh.set_state_idle()


func _process_wander() -> void:
	# If the player is within the view cone and line of sight, switch to chase.
	if player and _check_player_line_of_sight():
		set_state(BehaviourState.CHASE)
		_process_chase()
		return
	
	# Find a new target if we reached the previous.
	if nav.is_target_reached():
		find_next_nav_location()
		patrol_timer.start()
		
	nav.target_position = next_nav_location
	
	_move_along_path()


#-------------------------------------------------------------------------------
func _process_chase() -> void:
	if player:
		_check_player_line_of_sight()
		
		if player_found:
			nav.target_position = player.position
		else:
			nav.target_position = next_nav_location
			set_state(BehaviourState.WANDER)
	else:
		print_debug("Player ref is not valid during chase state")
	
	_move_along_path()


#-------------------------------------------------------------------------------
func _check_player_line_of_sight() -> bool:
	if player:
		raycast.target_position = to_local(player.global_position)
		raycast.force_raycast_update()
		
		if raycast.is_colliding() && raycast.get_collider() == player:
			player_found = true
			_player_memory_timer.start()
			return true
			
	return false


#-------------------------------------------------------------------------------
func _move_along_path() -> void:
	var next_location = nav.get_next_path_position()
	
	if next_location != global_transform.origin:
		look_at(next_location, Vector3(0,1,0))
		rotation.x = 0
		rotation.z = 0
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * speed
	velocity = velocity.move_toward(new_velocity,0.25)


#-------------------------------------------------------------------------------
func find_next_nav_location():
	var start_pos = global_transform.origin
	var random_X = randi_range(-10, 10)
	var random_Z = randi_range(-10, 10)
	next_nav_location = Vector3(start_pos.x + (random_X), start_pos.y, start_pos.z + (random_Z))


#-------------------------------------------------------------------------------
# Patrol timer expired
func _on_timer_timeout() -> void:
	find_next_nav_location()


#-------------------------------------------------------------------------------
# Memory timer expired
func _forget_player() -> void:
	if _state == BehaviourState.CHASE:
		set_state(BehaviourState.WANDER)
	
	player_found = false


#-------------------------------------------------------------------------------
# Player entered view cone
func _on_area_3d_body_entered(body: Node3D) -> void:
	if _state != BehaviourState.REST:
		if body.is_in_group("player"):
			player = body
			if _check_player_line_of_sight():
				set_state(BehaviourState.CHASE)


#-------------------------------------------------------------------------------
# Player exited view cone
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player = null
		set_state(BehaviourState.WANDER)


#-------------------------------------------------------------------------------
func _check_for_player_collision(body: Node3D) -> void:
	if body.is_in_group("player"):
		get_node("/root/Main")._game_over()


#-------------------------------------------------------------------------------
func _on_start_idle_timer_timeout() -> void:
	set_state(BehaviourState.WANDER)


#-------------------------------------------------------------------------------
