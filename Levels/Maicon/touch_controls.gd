extends Control
@onready var virtual_joystick: VirtualJoystick = $VirtualJoystick
@onready var virtual_joystick_2: VirtualJoystick = $VirtualJoystick2
@onready var interact_button: Button = $InteractButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not DisplayServer.is_touchscreen_available():
		virtual_joystick.hide()
		virtual_joystick_2.hide()
		interact_button.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# TODO: if possible make it smoother later
	# Reset mouse movements to allow only from touch
	var mouse_reset_ev = InputEventMouseMotion.new()
	mouse_reset_ev.relative.y = 0;
	mouse_reset_ev.relative.x = 0;
	Input.parse_input_event(mouse_reset_ev)
	if Input.is_action_pressed("look_up"):
		var ev = InputEventMouseMotion.new()
		ev.relative.y = -10;
		Input.parse_input_event(ev)
	if Input.is_action_pressed("look_down"):
		var ev = InputEventMouseMotion.new()
		ev.relative.y = 10;
		Input.parse_input_event(ev)
	if Input.is_action_pressed("look_left"):
		var ev = InputEventMouseMotion.new()
		ev.relative.x = -10;
		Input.parse_input_event(ev)
	if Input.is_action_pressed("look_right"):
		var ev = InputEventMouseMotion.new()
		ev.relative.x = 10;
		Input.parse_input_event(ev)


func _on_button_down() -> void:
	var ev = InputEventAction.new()
	ev.action = "interact"
	ev.pressed = true
	Input.parse_input_event(ev)

func _on_button_up() -> void:
	var ev = InputEventAction.new()
	ev.action = "interact"
	ev.pressed = false
	Input.parse_input_event(ev)
