extends Control

class_name credits

@export var speed: float = 10

@onready var credits_movement: VBoxContainer = $Credits
func _process(delta):
	credits_movement.position -= Vector2(0, speed * delta)
	if credits_movement.position.y + credits_movement.size.y < 0:
		get_tree().change_scene_to_file("res://screens/main_menu.tscn")
