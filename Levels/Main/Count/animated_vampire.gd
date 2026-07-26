extends Node3D

func set_state_idle():
	$Armature.hide()
	$Vampire_Idle.show()


func set_state_walking():
	$Armature.show()
	$Vampire_Idle.hide()
	$AnimationPlayer.play("Animations/WalkCycle")


func set_state_creeping():
	$Armature.show()
	$Vampire_Idle.hide()
	$AnimationPlayer.play("Animations/Creep")


func set_state_floating():
	$Armature.show()
	$Vampire_Idle.hide()
	$AnimationPlayer.play("Animations/Float")
	
