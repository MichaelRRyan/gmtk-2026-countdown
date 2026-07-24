extends Control
class_name DebugHud

@export var task_object_sample: TaskObjectBase
@onready var task_complete_label: Label = $Label

func _ready() -> void:
	task_complete_label.visible = false
	task_object_sample.on_task_complete.connect(_on_task_complete)
	
func _on_task_complete():
	task_complete_label.visible = true
