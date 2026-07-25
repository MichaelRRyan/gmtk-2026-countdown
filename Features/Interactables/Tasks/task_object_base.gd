extends Interactable
class_name TaskObjectBase

signal on_task_completed(task_object: TaskObjectBase)
signal on_task_updated(task_object: TaskObjectBase, interact_level_current: float, interact_level_end: float)
signal on_task_reset(task_object: TaskObjectBase)

@export_category("Completion Rates")
@export var interact_increase_rate: float = 0.1
@export var interact_delay_before_decrease: float = 0.05
@export var interact_decrease_rate: float = 0.05
@export var interact_level_start: float = 0.0
@export var interact_level_end: float = 100.0

@export_category("Pre-Requisites")
@export var required_item_type: EquippableObject.ItemType = EquippableObject.ItemType.NONE
@export var consume_item_on_completion: bool = false

@export_category("Display")
@export var objective_text: String = "DEBUG"

@export_category("Debug Config")
@export var is_active: bool = true

var is_increasing: bool = false
var interact_level_current: float = interact_level_start
var is_task_complete: bool = false

func is_interactable(player: Player) -> Array:
	var has_pre_requisites: bool = required_item_type != EquippableObject.ItemType.NONE
	var pre_requisites_met: bool = player.holdable_item_manager.held_item and required_item_type == player.holdable_item_manager.held_item.item_type
	var item_is_missing: bool = has_pre_requisites and !pre_requisites_met and not is_task_complete
	var interaction_is_available: bool = is_active and not is_task_complete
	var is_interactable: bool = !item_is_missing and interaction_is_available
	var object_description: String = ""
	hud.set_crosshair_interactable(interaction_is_available)
	if item_is_missing:
		var item_type_name: String = EquippableObject.ItemType.keys()[required_item_type]
		object_description = "Missing: %s" % item_type_name.to_lower()
		hud.show_equippable_object_description(object_description, true)

	return [is_interactable, object_description]

func _process(delta: float) -> void:
	if not is_active or is_task_complete or is_increasing or interact_level_current <= 0:
		return
		
	interact_level_current -= (interact_decrease_rate * delta)
	on_task_updated.emit(self, interact_level_current, interact_level_end)
	_undo_action()

func interact_hold(player: Player, delta: float) -> void:
	if is_task_complete or not is_active:
		return

	if interact_level_current >= interact_level_end:
		is_task_complete = true
		on_task_completed.emit(self)
		return
	
	is_increasing = true
	interact_level_current += (interact_increase_rate * delta)
	on_task_updated.emit(self, interact_level_current, interact_level_end)
	
	_perform_action()
	
func interact_release(player: Player, delta: float) -> void:
	is_increasing = false	
	
func _perform_action() -> void:
	pass
	
func _undo_action() -> void:
	pass


#-------------------------------------------------------------------------------
func _reset_task():
	is_active = true
	is_task_complete = false
	interact_level_current = interact_level_start
	on_task_reset.emit(self)
	
	
#-------------------------------------------------------------------------------
