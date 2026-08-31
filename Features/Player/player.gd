extends CharacterBody3D
class_name Player

@export var move_speed: float = 3.2
@export var running_move_speed: float = 4.5
@export var acceleration: float = 4
@export var deceleration: float = 6
@export var mouse_sensitivity: float = 0.002
@export var max_look_up: float = deg_to_rad(80)
@export var max_look_down: float = deg_to_rad(-80)
@export var hiding_min_look: float = deg_to_rad(-40)
@export var hiding_max_look: float = deg_to_rad(40)
@export var gravity: float = 9.8
@export var jump_height: float = 0.5

@onready var jump_speed: float = sqrt(2 *  gravity * jump_height)

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var holdable_item_manager: HoldableItemManager = $Head/Camera3D/HoldableItemManager
@onready var _footstep_audio : FootstepAudio = $FootstepAudio

var camera_rot_x: float = 0.0
var camera_rot_y: float = 0.0
var velocity_desired: Vector3 = Vector3.ZERO
var _current_interactable: Interactable = null
var _is_interact_held = false
var hud: HUD

var is_hiding: bool = false
var is_frozen: bool = false


#-------------------------------------------------------------------------------
func _ready() -> void:
	# Capture mouse when game starts.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	holdable_item_manager.camera = camera


#-------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if is_frozen:
		return
	# Handle mouse movement for view direction.
	if event is InputEventMouseMotion:
		camera_rot_y -= event.relative.x * mouse_sensitivity
		camera_rot_x -= event.relative.y * mouse_sensitivity
		camera_rot_x = clamp(camera_rot_x, max_look_down, max_look_up)
		
		if is_hiding:
			camera_rot_y = clamp(camera_rot_y, hiding_min_look, hiding_max_look)
		
		rotation.y = camera_rot_y
		head.rotation.x = camera_rot_x
	
	# PLACEHOLDER - TODO: Remove this later.
	if event.is_action_pressed("exit"):
		get_tree().quit()


#-------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	if not is_hiding:
		_process_movement(delta)
	
	_process_interactions(delta)
	
	if Input.is_action_just_pressed("show_tasks"):
		hud.toggle_tasks()
	
	if Input.is_action_just_pressed("drop_item"):
			holdable_item_manager.drop_current_item()


#-------------------------------------------------------------------------------
func _process_interactions(delta : float):
	var focused_interact: Interactable = _get_current_interactable_object()
	if focused_interact:
		
		# Release old interactable if no longer the currently focused interact.
		if _current_interactable and _current_interactable != focused_interact:
			_unfocus_current_interactable(delta)
		
		# Set the new currently focused interactable.
		_current_interactable = focused_interact
		
		if focused_interact.is_interactable(self):
			hud.set_crosshair_interactable(true)
			
			# Process singular interact inputs.
			if Input.is_action_just_pressed("interact"):
				_current_interactable.interact_press(self, delta)
			
			# Process hold interact inputs.
			elif Input.is_action_pressed("interact"):
				_current_interactable.interact_hold(self, delta)
				_is_interact_held = true
			
			# Release any held interacts when no longer held.
			elif _is_interact_held:
				_is_interact_held = false
				_current_interactable.interact_release(self, delta)
	
	# If no focused interacts and we're storing an interact, release it.
	elif _current_interactable:
		_unfocus_current_interactable(delta)


#-------------------------------------------------------------------------------
func _unfocus_current_interactable(delta):
	if _is_interact_held:
		_is_interact_held = false
		_current_interactable.interact_release(self, delta)
	
	_current_interactable.interact_unfocused(self, delta)
	hud.reset_interactable_hud_elements()
	_current_interactable = null


#-------------------------------------------------------------------------------
## Apply movement, gravity, and acceleration each physics frame.
func _process_movement(delta: float) -> void:
	if is_frozen:
		return
	
	var direction : Vector3 = _get_movement_input()
	
	if Input.is_action_pressed("run"):
		velocity_desired = direction * running_move_speed
		_footstep_audio.set_speed_multiplier(1.7)
	else:
		velocity_desired = direction * move_speed
		_footstep_audio.set_speed_multiplier(1.0)
	
	# Horizontal components
	var vel_h = velocity
	vel_h.y = 0
	
	var rate = acceleration if direction.length() > 0 else deceleration
	vel_h = vel_h.lerp(velocity_desired, rate * delta)

	# Apply back to velocity
	velocity.x = vel_h.x
	velocity.z = vel_h.z
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_speed
	
	move_and_slide()
	
	if direction.length() > 0 and is_on_floor():
		_footstep_audio.play()
	else:
		_footstep_audio.stop()


#-------------------------------------------------------------------------------
## Get the movement related user input and return it as a movement vector.
func _get_movement_input() -> Vector3:
	# Process movement direction from input.
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


#-------------------------------------------------------------------------------
func _get_current_interactable_object() -> Interactable:
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider:
			var interactable_object: Interactable = collider.owner as Interactable
			return interactable_object
	return null


#-------------------------------------------------------------------------------
