extends Control

class_name  main_menu

var tree: SceneTree = null
@export var main_level: PackedScene
@onready var container : HBoxContainer = $ButtonsContainer

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	tree = get_tree()

func _on_exit_pressed():
	tree.quit()

func _on_credits_pressed():
	tree.change_scene_to_file("res://Screens/Credits.tscn")


func _on_play_pressed():
	tree.change_scene_to_packed(main_level)
