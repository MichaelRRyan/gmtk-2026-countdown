extends Interactable
class_name EquippableObject

@export_category("Debug Config")
@export var is_active: bool = true

@export_category("Display")
@export var object_name: String = "DEBUG"
@export var postition_equipped_camera_offset: Vector3
@export var rotation_equipped_camera_offset: Vector3

@onready var rigid_body: RigidBody3D = $RigidBody3D
@onready var collision_shape: CollisionShape3D = $RigidBody3D/CollisionShape3D

func is_interactable() -> bool:
	return true

func interact_press(player: Player, delta: float) -> void:
	rigid_body.freeze = true
	collision_shape.disabled = true
	player.holdable_item_manager.try_pickup(self)
