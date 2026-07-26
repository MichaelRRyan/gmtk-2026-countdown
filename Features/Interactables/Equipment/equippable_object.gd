extends Interactable
class_name EquippableObject

enum ItemType { NONE, STICK, KEY, CLOTH }

@export_category("Debug Config")
@export var is_active: bool = true

@export_category("Display")
@export var object_name: String = "DEBUG"
@export var postition_equipped_camera_offset: Vector3
@export var rotation_equipped_camera_offset: Vector3

@export var item_type: ItemType

@onready var rigid_body: RigidBody3D = $RigidBody3D
@onready var collision_shape: CollisionShape3D = $RigidBody3D/CollisionShape3D

func check_is_interactable(_player: Player) -> Array:
	var description = object_name if is_active else ""
	hud.show_equippable_object_description(description, is_active)
	hud.set_crosshair_interactable(is_active)
	
	return [is_active, ""]

func interact_press(player: Player, _delta: float) -> void:
	rigid_body.freeze = true
	collision_shape.disabled = true
	player.holdable_item_manager.try_pickup(self)
