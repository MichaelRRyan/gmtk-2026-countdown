extends Control
@onready var virtual_joystick: VirtualJoystick = $VirtualJoystick
@onready var virtual_joystick_2: VirtualJoystick = $VirtualJoystick2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not DisplayServer.is_touchscreen_available():
		virtual_joystick.hide()
		virtual_joystick_2.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# TODO: if possible make it smoother later
	if Input.is_action_pressed("look_up"):
		var ev = InputEventMouseMotion.new()
		# Set as ui_left, pressed.
		ev.relative.y = -10;
		Input.parse_input_event(ev)
	if Input.is_action_pressed("look_down"):
		var ev = InputEventMouseMotion.new()
		# Set as ui_left, pressed.
		ev.relative.y = 10;
		Input.parse_input_event(ev)
	if Input.is_action_pressed("look_left"):
		var ev = InputEventMouseMotion.new()
		# Set as ui_left, pressed.
		ev.relative.x = -10;
		Input.parse_input_event(ev)
	if Input.is_action_pressed("look_right"):
		var ev = InputEventMouseMotion.new()
		# Set as ui_left, pressed.
		ev.relative.x = 10;
		Input.parse_input_event(ev)
