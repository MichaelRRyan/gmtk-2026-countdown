extends Node3D

@onready var _wood_footsteps = [
	preload("res://Audio/SFX/step_wood_0.wav"),
	preload("res://Audio/SFX/step_wood_1.wav"),
	preload("res://Audio/SFX/step_wood_2.wav")
]

@onready var _stone_footsteps = [
	preload("res://Audio/SFX/step_stone_0.wav"),
	preload("res://Audio/SFX/step_stone_1.wav"),
	preload("res://Audio/SFX/step_stone_2.wav")
]

var is_on_wood_floor = true


func play():
	if $FootstepFrequency.is_stopped():
		_play_footstep()
		$FootstepFrequency.start()


func stop():
	$FootstepFrequency.stop()


func _on_footstep_frequency_timeout():
	_play_footstep()
	$FootstepFrequency.start(randf_range(0.4, 0.6))


func _play_footstep():
	if is_on_wood_floor:
		$AudioStreamPlayer3D.stream = _wood_footsteps[randi_range(0, 2)]
	else:
		$AudioStreamPlayer3D.stream = _stone_footsteps[randi_range(0, 2)]
		
	$AudioStreamPlayer3D.play()
	

func _on_audio_zone_area_detector_area_entered(area : Area3D):
	if area.is_in_group("wood_floor"):
		is_on_wood_floor = true
	else:
		is_on_wood_floor = false
