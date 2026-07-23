extends Node3D
class_name HoldableItemManager

var held_item: Node3D = null

# Try to pick up an item (like a watering can)
func try_pickup(item: Node3D) -> void:
	if held_item != null:
		drop_current_item()

	held_item = item
	
	if item is RigidBody3D:
		item.freeze = true
	
	item.is_held = true
	item.get_node("CollisionShape3D").disabled = true
	item.reparent(self)
	item.transform.origin = Vector3.ZERO
	item.transform.basis = Basis.from_euler(Vector3(0, deg_to_rad(-90.0), 0))
	

# Drop the currently held item
func drop_current_item() -> void:
	if held_item == null:
		return
	
	if held_item is RigidBody3D:
		held_item.freeze = false

	held_item.reparent(get_tree().get_root())
	held_item.get_node("CollisionShape3D").disabled = false
	held_item.is_held = false
	held_item = null

# Get the held item
func get_held_item() -> Node3D:
	return held_item

# Check if holding an item in a specific group
func is_holding(item_group : String) -> bool:
	return held_item != null and held_item.is_in_group(item_group)
