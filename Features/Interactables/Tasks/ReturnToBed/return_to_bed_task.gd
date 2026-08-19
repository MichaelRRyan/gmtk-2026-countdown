class_name ReturnToBedTask
extends TaskObjectBase


#-------------------------------------------------------------------------------
func _on_body_entered(body):
	if is_active and body is Player:
		is_task_complete = true
		on_task_completed.emit(self)


#-------------------------------------------------------------------------------
func _on_body_exited(body):
	if is_task_complete and body is Player:
		is_task_complete = false
		on_task_reset.emit(self)


#-------------------------------------------------------------------------------
