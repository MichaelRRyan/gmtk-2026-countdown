class_name CountdownTimer
extends Node

@onready var _label: RichTextLabel = $Label


#-------------------------------------------------------------------------------
func display_current_time(time: int):
	var minutes: int = floor(time / 60.0)
	var seconds: int = time % 60
	_label.text = "Time Remaining: %02d:%02d" % [minutes, seconds]


#-------------------------------------------------------------------------------
