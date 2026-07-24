extends TextureRect
class_name ObjectivesList

@onready var objectives_list_container: VBoxContainer = $ObjectivesListContainer
var labels: Dictionary

func set_task_objective(task_object: TaskObjectBase):
	var new_label: Label = Label.new()
	new_label.text = task_object.objective_text
	objectives_list_container.add_child(new_label)
	labels[task_object] = new_label
	
func remove_task_objective(task_object: TaskObjectBase):
	var label_to_remove = labels[task_object]
	if label_to_remove:
		labels.erase(task_object)
		objectives_list_container.remove_child(label_to_remove)
		label_to_remove.queue_free()
