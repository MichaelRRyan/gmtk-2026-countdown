extends Interactable

class_name HidingSpot

@export_category("Debug Config")
@export var is_active: bool = true

@export_category("Display")
@export var object_name: String = "Hiding Spot"

@export_category("Settings")
@export var offset: Vector3 = Vector3(0,0,0)

var player_handle: Player

func _process(delta):
	if Input.is_action_pressed("leave_hiding_Spot"):
		player_handle.position += offset
		player_handle.is_hiding = false

func is_interactable(player: Player) -> Array:
	var description = object_name if is_active else ""
	hud.show_equippable_object_description(description, is_active)
	hud.set_crosshair_interactable(is_active)
	
	return [is_active, ""]

func interact_press(player: Player, delta: float) -> void:
	if player_handle == null:
		player_handle = player
	
	if player.is_hiding:
		player.position += offset
		player.is_hiding = false
		hud._hide_hiding_spot()
	else:
		player.position = position - offset
		player.look_at(position)
		player.camera_rot_y = player.rotation.y
		player.is_hiding = true
		hud._show_hiding_spot()
