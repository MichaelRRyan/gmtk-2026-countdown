extends Node3D

enum State {
	IDLE,
	WALKING,
	CREEPING,
	FLOATING
}

var _current_state = State.IDLE


func set_state_idle():
	if _current_state != State.IDLE:
		_current_state = State.IDLE
		$Armature.hide()
		$Vampire_Idle.show()


func set_state_walking():
	if _current_state != State.WALKING:
		_current_state = State.WALKING
		$Armature.show()
		$Vampire_Idle.hide()
		$AnimationPlayer.play("Animations/WalkCycle")


func set_state_creeping():
	if _current_state != State.CREEPING:
		_current_state = State.CREEPING
		$Armature.show()
		$Vampire_Idle.hide()
		$AnimationPlayer.play("Animations/Creep")


func set_state_floating():
	if _current_state != State.FLOATING:
		_current_state = State.FLOATING
		$Armature.show()
		$Vampire_Idle.hide()
		$AnimationPlayer.play("Animations/Float")
	
