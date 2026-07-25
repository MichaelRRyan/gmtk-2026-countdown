extends TaskObjectBase
class_name TaskCleanBlood

@onready var blood_sprite: Sprite3D = $StaticBody3D/BloodSprite

func _update_color() -> void:
	blood_sprite.modulate.a = lerp(1.0, 0.0, interact_level_current)

func _perform_action() -> void:
	_update_color()
	
func _undo_action() -> void:
	_update_color()
