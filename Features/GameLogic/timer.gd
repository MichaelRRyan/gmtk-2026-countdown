extends Node

class_name CountDownTimer

signal timer_completed

@onready var label: RichTextLabel = $Label

@onready
var dayTimer: Timer = $DayTimer

func _process(delta):
	if !dayTimer.is_stopped():
		display_current_time(dayTimer.time_left)
	
func display_current_time(time: int):
	var minutes: int = floor(time / 60.0)
	var seconds: int = time % 60
	label.text = "Time Remaining: %02d:%02d" % [minutes, seconds]
	
func _start_timer():
	dayTimer.start()

func _on_timer_timeout():
	timer_completed.emit()
