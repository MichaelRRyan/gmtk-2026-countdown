extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var new_velocity = Vector3(0,0,0)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	velocity = velocity.move_toward(new_velocity, 0.25)
	move_and_slide()

func move_AI_randomly():
	var start_pos = get_parent().get_child(2).position
	var navigation_agent_3d = get_node("NavigationAgent3D") 
	var random_X = randi_range(-3, 3)
	var random_Y = randi_range(-2, 2)
	var random_Z = randi_range(-3, 3)
	var random_loc = Vector3(start_pos.x + (random_X), start_pos.y + (random_Y), start_pos.z + (random_Z))
	navigation_agent_3d.target_position = random_loc
	var next_path_location = navigation_agent_3d.get_next_path_position()
	new_velocity = (next_path_location - global_position)* 2


func _on_timer_timeout() -> void:
	move_AI_randomly()
