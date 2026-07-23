extends Node3D
class_name LandingScreen

@export var game: PackedScene
@export var countdown_amount: int = 5

@onready var countdown_text: RichTextLabel = $MenuScreen/CountDownText
@onready var countdown_timer: Timer = $CountDownTimer

var current_countdown_amount: int = countdown_amount

func _ready() -> void:
	set_timer(current_countdown_amount)
	countdown_timer.timeout.connect(_on_timeout)
	
func set_timer(new_countdown_amount: int):
	current_countdown_amount = new_countdown_amount
	countdown_text.text = "%d" % current_countdown_amount
	
func _on_timeout():
	if current_countdown_amount > 1:
		set_timer(current_countdown_amount - 1)
	else:
		get_tree().change_scene_to_file("res://Levels/michaels_test_level.tscn")
