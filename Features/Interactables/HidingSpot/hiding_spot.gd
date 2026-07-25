extends Interactable

class_name HidingSpot

@export_category("Settings")
@export var location_offset: Vector3

func is_interactable(player: Player) -> bool:
	return true

func interact_hold(player: Player, delta: float) -> void:
	if not player.is_hiding:
		player.position += location_offset
		player.rotate_to_look_at_hiding_spot(position)
	else:
		player.position -= location_offset
	player.is_hiding = !player.is_hiding

	
