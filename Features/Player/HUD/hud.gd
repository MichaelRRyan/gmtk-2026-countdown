extends Control
class_name HUD

@export_group("Crosshair")
@export var crosshair_normal_color: Color
@export var crosshair_interactable_color: Color

@export_group("Task Complete")
@export var task_complete_display_length: float = 2.0
@export var task_complete_fadeout_speed_scale: float = 1.5

@onready var crosshair: TextureRect = $Crosshair
@onready var task_complete: RichTextLabel = $TaskComplete
@onready var task_complete_timer: Timer = $TaskComplete/TaskCompleteTimer
@onready var task_complete_animation_player: AnimationPlayer = $TaskComplete/TaskCompleteAnimationPlayer
@onready var task_progress_bar: ProgressBar = $TaskProgressBar
@onready var objectives_list: ObjectivesList = $ObjectivesList
@onready var equippable_object_label: RichTextLabel = $EquippableObject

func _ready() -> void:
	set_crosshair_interactable(false)
	show_equippable_object_description("", false)
	
	task_complete.modulate.a = 0.0
	task_complete_timer.timeout.connect(_task_complete_timeout)
	task_complete_animation_player.speed_scale = task_complete_fadeout_speed_scale
	
	task_progress_bar.visible = false

func set_crosshair_interactable(is_interactable: bool) -> void:
	crosshair.visible = is_interactable
	#var color_to_set: Color = crosshair_interactable_color if is_interactable else crosshair_normal_color
	#crosshair.modulate = color_to_set
	
func set_task_meter(interact_level_current: float, interact_level_end: float):
	if interact_level_current <= 0:
		task_progress_bar.visible = false
		return
	
	var percent: float = interact_level_current / interact_level_end * 100
	task_progress_bar.visible = task_progress_bar.value <= percent
	task_progress_bar.value = percent
	
func show_task_complete() -> void:
	task_progress_bar.visible = false
	task_complete.modulate.a = 1.0
	task_complete_timer.start(task_complete_display_length)
	
func show_equippable_object_description(text: String, show: bool):
	if show:
		equippable_object_label.text = text
	equippable_object_label.visible = show
	
func reset_interactable_hud_elements():
	task_progress_bar.visible = false
	equippable_object_label.visible = false
	set_crosshair_interactable(false)
	
func _task_complete_timeout() -> void:
	task_complete_animation_player.play("task_complete_fadeout")
