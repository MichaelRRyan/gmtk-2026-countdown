extends Node3D
class_name Interactable

@export var is_hold_action: bool = true

func is_interactable(player: Player) -> bool:
	return false
	
func interact_press(player: Player, delta: float) -> void:
	pass
	
func interact_hold(player: Player, delta: float) -> void:
	pass
	
func interact_release(player: Player, delta: float) -> void:
	pass
