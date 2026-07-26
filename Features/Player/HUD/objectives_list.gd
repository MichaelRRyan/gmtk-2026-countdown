extends TextureRect
class_name ObjectivesList

@onready var objectives_list_container: VBoxContainer = $ObjectivesListContainer
@onready var tasks_left_label: Label = $TasksLeftLabel

var labels: Dictionary[TaskObjectBase.TaskType, ObjectiveItem]

func reset():
	labels.clear()
	for child in objectives_list_container.get_children():
		objectives_list_container.remove_child(child)
		child.queue_free()

func set_task_objective(task_object: TaskObjectBase):
	if labels.is_empty() or !labels.has(task_object.task_type):		
		var new_label: ObjectiveItem = ObjectiveItem.new()
		new_label.add_objective(task_object)
		labels[task_object.task_type] = new_label
		objectives_list_container.add_child(new_label)
	else: 
		labels[task_object.task_type].add_objective(task_object)
	
func remove_task_objective(task_object: TaskObjectBase):
	var label_to_decrement = labels[task_object.task_type]
	if label_to_decrement:
		if label_to_decrement.current + 1 == label_to_decrement.total:
			labels.erase(task_object.task_type)
			objectives_list_container.remove_child(label_to_decrement)
			label_to_decrement.queue_free()
		else:
			label_to_decrement.complete_objective(task_object)

func set_tasks_left(tasks_left: int):
	tasks_left_label.text = "Tasks Left: %d" % tasks_left

func _on_toggle_button_pressed() -> void:
	var ev = InputEventAction.new()
	ev.action = "show_tasks"
	ev.pressed = true
	Input.parse_input_event(ev)
