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
@onready var memory_timer = $MemoryTimer
@onready var patrol_timer = $PatrolTimer

var _state : BehaviourState = BehaviourState.WANDER
var speed : float = 2.5
var gravity : float = 9.8
var start_searching : bool = false
var next_nav_location : Vector3 = Vector3.ZERO
var player_found : bool = false
var player : Player = null


func _ready() -> void:
	find_next_nav_location()
	$Vampire.set_state_idle()


#-------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if !start_searching:
		return
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y -= 2
	
	match _state:
		BehaviourState.WANDER:
			_process_wander()
		BehaviourState.CHASE:
			_process_chase()
	
	
	var horizontal_vel = Vector2(velocity.x, velocity.z)
	if horizontal_vel.length_squared() > 0:
		$FootstepAudio.play()
		$Vampire.set_state_walking()
	else:
		$FootstepAudio.stop()
		$Vampire.set_state_idle()


func _process_wander() -> void:
	if nav.is_target_reached():
		find_next_nav_location()
		patrol_timer.start()
		
	nav.target_position = next_nav_location
	
	_move_along_path()


func _move_along_path() -> void:
	var next_location = nav.get_next_path_position()
	
	if next_location != global_transform.origin:
		look_at(next_location, Vector3(0,1,0))
		rotation.x = 0
		rotation.z = 0
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * speed
	velocity = velocity.move_toward(new_velocity,0.25)
	move_and_slide()


func _process_chase() -> void:
	if player:
		raycast.target_position = to_local(player.global_position)
		raycast.force_raycast_update()
		if raycast.is_colliding() && raycast.get_collider() == player:
			player_found = true
			memory_timer.start()
		if player_found:
			nav.target_position = player.position
		else:
			nav.target_position = next_nav_location
			_state = BehaviourState.WANDER
	else:
		print_debug("Player ref is not valid during chase state")
	
	_move_along_path()
	

func find_next_nav_location():
	var start_pos = global_transform.origin
	var random_X = randi_range(-10, 10)
	var random_Z = randi_range(-10, 10)
	next_nav_location = Vector3(start_pos.x + (random_X), start_pos.y, start_pos.z + (random_Z))


# Patrol timer expired
func _on_timer_timeout() -> void:
	find_next_nav_location()


# Memory timer expired
func _forget_player() -> void:
	player_found = false
	_state = BehaviourState.WANDER
	


# Player entered view cone
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player = body
		_state = BehaviourState.CHASE
		


# Player exited view cone
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player = null
		_state = BehaviourState.WANDER
		


func _start_searching_area() -> void:
	start_searching = true


func _count_finished_searching() -> void:
	pass


func _check_for_player_collision(body: Node3D) -> void:
	if body.is_in_group("player"):
		get_node("/root/Main")._game_over()
