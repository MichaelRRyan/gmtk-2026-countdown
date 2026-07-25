extends TextureRect
class_name ObjectivesList

@onready var objectives_list_container: VBoxContainer = $ObjectivesListContainer
var labels: Dictionary[TaskObjectBase.TaskType, ObjectiveItem]

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
