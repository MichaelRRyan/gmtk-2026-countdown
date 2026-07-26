extends Node

class_name  CountTimer

signal start_checking_area
signal finished_checking

@export_category("Timers")
@export var time_to_wait_start_checking: float = 5
@export var time_to_wait_return_to_bed: float = 60

@onready var start_checking_timer = $TimeToStartCheckingArea
@onready var finish_checking_timer = $TimeToFinishChecking

func _ready():
	start_checking_timer.wait_time = time_to_wait_start_checking
	finish_checking_timer.wait_time = time_to_wait_return_to_bed
	start_checking_timer.start()
	start_checking_area.emit()


func _on_time_to_start_checking_area_timeout():
	finish_checking_timer.start()
	finished_checking.emit()


func _on_time_to_finish_checking_timeout():
	start_checking_timer.start()
	start_checking_area.emit()
