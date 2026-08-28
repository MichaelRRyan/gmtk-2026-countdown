class_name INote
extends Interactable

@export var text : String = "" 

#-------------------------------------------------------------------------------
func check_is_interactable(_player: Player) -> Array:
	return [ true, "" ]


#-------------------------------------------------------------------------------
