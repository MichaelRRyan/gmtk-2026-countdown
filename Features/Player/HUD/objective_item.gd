extends Label
class_name ObjectiveItem

var current: int = 0
var total: int = 0

func add_objective(task_object_base: TaskObjectBase):
	total += 1
	text = task_object_base.objective_text + (" (%d/%d)" % [current, total])
		
func complete_objective(task_object_base: TaskObjectBase):
	current = min(current + 1, total)
	text = task_object_base.objective_text + (" (%d/%d)" % [current, total])
	
