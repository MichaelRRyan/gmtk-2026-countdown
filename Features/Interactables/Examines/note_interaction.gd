class_name NoteInteraction
extends Interactable

@export var text : String = ""
@export var note_ui : PackedScene = null

var _note_showed = false

#-------------------------------------------------------------------------------
func check_is_interactable(_player: Player) -> Array:
	return [ true, "" ]


#-------------------------------------------------------------------------------
func interact_press(_player: Player, _delta: float) -> void:
	if _note_showed:
		_player.hud.hide_note()
		_note_showed = false
	else:
		_player.hud.show_note(text, note_ui)
		_note_showed = true


#-------------------------------------------------------------------------------
func interact_unfocused(_player : Player, _delta : float) -> void:
	_player.hud.hide_note()
	_note_showed = false


#-------------------------------------------------------------------------------
func _ready() -> void:
	$Label3D.text = text


#-------------------------------------------------------------------------------
