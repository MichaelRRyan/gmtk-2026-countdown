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
	label.text = "Day Left: %d" % dayTimer.time_left

func _on_timer_timeout():
	timer_completed.emit()
