extends CharacterBody3D
class_name Player

signal on_can_interact(can_interact: bool)

@export var move_speed: float = 3.2
@export var acceleration: float = 4
@export var deceleration: float = 6
@export var mouse_sensitivity: float = 0.002
@export var max_look_up: float = deg_to_rad(80)
@export var max_look_down: float = deg_to_rad(-80)
@export var max_hiding_look: float = deg_to_rad(40)
@export var min_hiding_look: float = deg_to_rad(-40)
@export var gravity: float = 9.8
@export var jump_height: float = 0.5

@onready var jump_speed: float = sqrt(2 *  gravity * jump_height)

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var holdable_item_manager: HoldableItemManager = $Head/Camera3D/HoldableItemManager

var camera_rot_x: float = 0.0
var camera_rot_y: float = 0.0
var velocity_desired: Vector3 = Vector3.ZERO
var last_interacted_object: Interactable = null
var is_hiding: bool = false


#-------------------------------------------------------------------------------
func _ready() -> void:
	# Capture mouse when game starts.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	holdable_item_manager.camera = camera


#-------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	# Handle mouse movement for view direction.
	if event is InputEventMouseMotion:
		camera_rot_y -= event.relative.x * mouse_sensitivity
		camera_rot_x -= event.relative.y * mouse_sensitivity
		camera_rot_x = clamp(camera_rot_x, max_look_down, max_look_up)
		
		if is_hiding:
			camera_rot_y = clamp(camera_rot_y, min_hiding_look, max_hiding_look)

		rotation.y = camera_rot_y
		head.rotation.x = camera_rot_x
	
	# PLACEHOLDER - TODO: Remove this.
	if event.is_action_pressed("exit"):
		get_tree().quit()


#-------------------------------------------------------------------------------
func _process_input() -> Vector3:
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
# Apply movement, gravity, and acceleration each physics frame.
func _process_movement(direction : Vector3, delta: float) -> void:
	velocity_desired = direction * move_speed
	
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
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_speed
	
	move_and_slide()
	

#-------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	if not is_hiding: _process_movement(_process_input(), delta)
	
	var has_pressed: bool = Input.is_action_just_pressed("interact")
	var is_holding: bool = Input.is_action_pressed("interact")
	
	var interactable_object: Interactable = _get_current_interactable_object()
	if interactable_object:
		on_can_interact.emit(true)
		
		if has_pressed and not interactable_object.is_hold_action:
			interactable_object.interact_press(self, delta)
		elif is_holding and interactable_object.is_hold_action:
			interactable_object.interact_hold(self, delta)
	else:
		on_can_interact.emit(false)
		if has_pressed:
			holdable_item_manager.drop_current_item()
		
	if last_interacted_object and not interactable_object:
		last_interacted_object.interact_release(self, delta)
	
	last_interacted_object = interactable_object
	
	
func _get_current_interactable_object() -> Interactable:
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider:
			var interactable_object: Interactable = collider.owner as Interactable
			if interactable_object and interactable_object.is_interactable(self):
				return interactable_object
	return null

func rotate_to_look_at_hiding_spot(target: Vector3) -> void:
	camera_rot_y *= -1
	rotation.y = camera_rot_y
	
	look_at(target)
	camera_rot_y = rotation.y
	camera_rot_x = rotation.x
	
