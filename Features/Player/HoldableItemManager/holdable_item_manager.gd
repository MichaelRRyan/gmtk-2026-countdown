extends Node3D
class_name HoldableItemManager

var held_item: EquippableObject = null
var held_item_transform: Transform3D
var camera: Camera3D

# Try to pick up an item (like a watering can)
func try_pickup(item: EquippableObject) -> void:
	#if held_item != null:
		#drop_current_item()

	held_item = item
	
	#item.get_node("CollisionShape3D").disabled = true
	item.reparent(camera, false)
	
	#item.translate_object_local(item.postition_equipped_camera_offset)
	#item.rotate_object_local(Vector3.X, item.rotation_equipped_camera_offset)
	item.transform.origin = item.postition_equipped_camera_offset
	item.rotation = item.rotation_equipped_camera_offset
	
# Drop the currently held item
func drop_current_item() -> void:
	if held_item == null:
		return
	
	held_item.rigid_body.freeze = false
	held_item.collision_shape.disabled = false
	held_item.reparent(get_tree().get_root())
	held_item = null

# Get the held item
func get_held_item() -> Node3D:
	return held_item
