extends Node3D
class_name Interactable

var hud: HUD

@export var is_hold_action: bool = true

func check_is_interactable(_player: Player) -> Array:
	return Array()
	
func interact_press(_player: Player, _delta: float) -> void:
	pass
	
func interact_hold(_player: Player, _delta: float) -> void:
	pass
	
func interact_release(_player: Player, _delta: float) -> void:
	pass
