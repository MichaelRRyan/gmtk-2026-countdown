class_name LevelManager
extends Node

signal all_levels_complete

@export var _level_root : Node = self

var _levels = [ "res://Levels/Days/day_1.tscn", "res://Levels/Days/day_2.tscn" ]
var _current_level : Node = null
var _current_level_index : int = -1


#-------------------------------------------------------------------------------
func switch_to_next_level() -> void:
	if _levels.is_empty():
		print_debug("ERROR: No levels in the levels array.")
	
	if _current_level:
		_current_level.queue_free()
	
	if _current_level_index + 1 < _levels.size():
		_current_level_index += 1
		
		var new_level_scene : PackedScene = load(_levels[_current_level_index])
		_current_level = new_level_scene.instantiate()
		_level_root.add_child(_current_level)
		
	else:
		all_levels_complete.emit()
		print_debug("ERROR: No more levels in the levels array.")


#-------------------------------------------------------------------------------
