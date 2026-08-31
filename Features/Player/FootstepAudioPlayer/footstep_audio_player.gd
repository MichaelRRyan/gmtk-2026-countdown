class_name FootstepAudio
extends Node3D

@export var step_frequency : float = 0.5
@export_range(-50, 50) var base_step_volume : float = 0

var speed_multiplier : float = 1.0

@onready var _audio_stream: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var _step_timer : Timer = $FootstepFrequency

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
	if _step_timer.is_stopped():
		_play_footstep()
		_step_timer.start()


func stop():
	_step_timer.stop()


func set_speed_multiplier(multiplier : float) -> void:
	speed_multiplier = multiplier
	
	# TODO: Implement increased volume when sprinting
	# 50 is the min, add 50 to handle negatives.
	#var volume = base_step_volume + 50
	#var new_db = (volume * multiplier) - 50
	#_audio_stream.volume_db = new_db


func _ready() -> void:
	_audio_stream.volume_db = base_step_volume
	

func _on_footstep_frequency_timeout():
	_play_footstep()
	_step_timer.start(step_frequency * (1 / speed_multiplier))


func _play_footstep():
	if is_on_wood_floor:
		_audio_stream.stream = _wood_footsteps[randi_range(0, 2)]
	else:
		_audio_stream.stream = _stone_footsteps[randi_range(0, 2)]
		
	_audio_stream.play()
	

func _on_audio_zone_area_detector_area_entered(area : Area3D):
	if area.is_in_group("wood_floor"):
		is_on_wood_floor = true
	else:
		is_on_wood_floor = false
