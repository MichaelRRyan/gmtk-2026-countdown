extends TaskObjectBase
class_name TaskPlateCleanup

@onready var plates_container: Node3D = $Plates

var plates: Array[Node3D]

func _ready() -> void:
	for child in plates_container.get_children():
		if child is Node3D:
			plates.append(child)
	
func _perform_action() -> void:
	_set_plate_visible(false)
	
func _undo_action() -> void:
	_set_plate_visible(true)
	
func _set_plate_visible(is_plate_visible: bool):
	var interval: float = 1.0 / (plates.size() - 1)
	var current_index: int = floor(interact_level_current / interval)
	plates[current_index].visible = is_plate_visible
	
func _set_hidden():
	for child in plates_container.get_children():
		if child is Node3D:
			child.visible = false
