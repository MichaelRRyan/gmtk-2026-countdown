class_name NoteUI
extends Control

@export var _display_label : Label = null


#-------------------------------------------------------------------------------
func set_text(text : String) -> void:
	_display_label.text = text


#-------------------------------------------------------------------------------
