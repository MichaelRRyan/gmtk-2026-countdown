extends Node3D
class_name Interactable

var hud: HUD

@export var is_hold_action: bool = true

func is_interactable(_player: Player):
	return check_is_interactable(_player)[0]

func check_is_interactable(_player: Player) -> Array:
	return [ false, "Cannot interact: No method definitions." ]
	
func interact_press(_player: Player, _delta: float) -> void:
	pass
	
func interact_hold(_player: Player, _delta: float) -> void:
	pass
	
func interact_release(_player: Player, _delta: float) -> void:
	pass

func interact_unfocused(_player : Player, _delta : float) -> void:
	pass
