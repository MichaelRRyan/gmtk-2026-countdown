extends CharacterBody3D

@onready var nav = $NavigationAgent3D
@onready var raycast = $RayCast3D
@onready var memory_timer = $"../MemoryTimer"
@onready var patrol_timer = $"../PatrolTimer"

var speed = 2.5
var gravity = 9.8
var next_nav_location
var player_found = false

func _ready() -> void:
	find_next_nav_location()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if nav.is_target_reached():
		find_next_nav_location()
		patrol_timer.start()
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y -= 2
	var player = get_node("/root/Main/Player")
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
	else:
		nav.target_position = next_nav_location
	var next_location = nav.get_next_path_position()
	if next_location != global_transform.origin:
		look_at(next_location)
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * speed
	velocity = velocity.move_toward(new_velocity,0.25)
	move_and_slide()

func find_next_nav_location():
	var start_pos = global_transform.origin
	var random_X = randi_range(-10, 10)
	var random_Z = randi_range(-10, 10)
	next_nav_location = Vector3(start_pos.x + (random_X), start_pos.y, start_pos.z + (random_Z))

func _on_timer_timeout() -> void:
	find_next_nav_location()
	

func _forget_player() -> void:
	player_found = false
