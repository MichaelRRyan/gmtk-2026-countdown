extends Control
class_name HUD

@export_group("Crosshair")
@export var crosshair_normal_color: Color
@export var crosshair_interactable_color: Color

@export_group("Task Complete")
@export var task_complete_display_length: float = 3.0

@onready var crosshair: TextureRect = $Crosshair
@onready var task_complete: RichTextLabel = $TaskComplete
@onready var task_progress_bar: ProgressBar = $TaskProgressBar

func _ready() -> void:
	set_crosshair_interactable(false)
	task_complete.visible = false
	task_progress_bar.visible = false

func set_crosshair_interactable(is_interactable: bool) -> void:
	var color_to_set: Color = crosshair_interactable_color if is_interactable else crosshair_normal_color
	crosshair.modulate = color_to_set
	
func set_task_meter(interact_level_current: float, interact_level_end: float):
	var percent: float = interact_level_current / interact_level_end * 100
	task_progress_bar.visible = true
	task_progress_bar.value = percent
