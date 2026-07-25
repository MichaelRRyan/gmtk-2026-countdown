extends Node

@onready var player: Player = $Player
@onready var hud: HUD = $HUD

var task_objects: Array[TaskObjectBase]
	
func _ready() -> void:
	player.hud = hud
	for child in get_children(true):
		if child is Interactable:
			child.hud = hud
			if child is TaskObjectBase:
				var task_object: TaskObjectBase = child as TaskObjectBase
				register_task(task_object)	

# These might well just be sequential, we will have to see
func register_task(task_object: TaskObjectBase):
	if task_object.is_active:
		task_object.on_task_updated.connect(_on_task_updated)
		task_object.on_task_completed.connect(_on_task_completed)
		hud.objectives_list.set_task_objective(task_object)
		task_objects.append(task_object)
	
func _on_task_updated(task_object: TaskObjectBase, interact_level_current: float, interact_level_end: float):
	hud.set_task_meter(interact_level_current, interact_level_end)
	
func _on_task_completed(task_object: TaskObjectBase):
	hud.show_task_complete()
	hud.objectives_list.remove_task_objective(task_object)
	
func on_can_interact(can_interact: bool):
	hud.set_crosshair_interactable(can_interact)
