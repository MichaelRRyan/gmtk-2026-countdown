extends Node

class_name CountDownTimer

signal timer_completed

@export_category("Timer")
@export var label: RichTextLabel
@export var totalTime: float 

@onready
var dayTimer: Timer = $DayTimer

func _ready():
	dayTimer.wait_time = totalTime
	dayTimer.start()

func _process(delta):
	var time_remaining: int = dayTimer.time_left
	var minutes: int = floor(time_remaining / 60.0)
	var seconds: int = time_remaining % 60
	label.text = "Time Remaining: %02d:%02d" % [minutes, seconds]
	
func _start_timer():
	dayTimer.start()

func _on_timer_timeout():
	timer_completed.emit()
