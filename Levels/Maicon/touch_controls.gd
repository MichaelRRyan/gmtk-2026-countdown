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
