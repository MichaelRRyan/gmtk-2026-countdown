extends CharacterBody3D
class_name Player

@export var move_speed: float = 5.0
@export var acceleration: float = 10.0
@export var deceleration: float = 20.0
@export var mouse_sensitivity: float = 0.002
@export var max_look_up: float = deg_to_rad(80)
@export var max_look_down: float = deg_to_rad(-80)
@export var gravity: float = -15.8
@export var jump_speed: float = 7.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var holdable_item_manager: HoldableItemManager = $Head/Camera3D/HoldableItemManager

var camera_rot_x: float = 0.0
var camera_rot_y: float = 0.0
var velocity_desired: Vector3 = Vector3.ZERO

func _ready() -> void:
	"""Capture mouse when game starts."""
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	"""Handle mouse movement for view direction."""
	if event is InputEventMouseMotion:
		camera_rot_y -= event.relative.x * mouse_sensitivity
		camera_rot_x -= event.relative.y * mouse_sensitivity
		camera_rot_x = clamp(camera_rot_x, max_look_down, max_look_up)

		rotation.y = camera_rot_y
		head.rotation.x = camera_rot_x
	
	# PLACEHOLDER - TODO: Remove this.
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _process_input() -> Vector3:
	"""Process movement direction from input."""
	var direction := Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_back"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	
	return direction.normalized()

func _physics_process(delta: float) -> void:
	"""Apply movement, gravity, and acceleration each physics frame."""
	var direction := _process_input()
	velocity_desired = direction * move_speed
	
	# Horizontal components
	var vel_h = velocity
	vel_h.y = 0
	
	var diff = velocity_desired - vel_h
	var rate = acceleration if diff.length() > 0 else deceleration
	
	vel_h = vel_h.lerp(velocity_desired, rate * delta)

	# Apply back to velocity
	velocity.x = vel_h.x
	velocity.z = vel_h.z
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_speed
	
	move_and_slide()
	
	if Input.is_action_just_pressed("interact"):
		_attempt_interaction()
	elif Input.is_action_pressed("interact"):
		_attempt_task(delta)
		

func _attempt_interaction() -> void:
	"""If raycast collides with NPC or object, call its interact()."""
	if raycast.is_colliding():
		var collider = raycast.get_collider()
	
			
		if collider and collider.has_method("interact"):
			
			collider.interact(holdable_item_manager.get_held_item())
			
			#if collider is WateringCan:
			#	holdable_item_manager.try_pickup(collider)
		else:
			holdable_item_manager.drop_current_item()
	else:
		holdable_item_manager.drop_current_item()
		
func _attempt_task(delta: float) -> void:
	if raycast.is_colliding():
		var collider: Object = raycast.get_collider()
		var task_object: TaskObjectBase = collider.owner
		if task_object:
			task_object.interact_hold(delta)
			
