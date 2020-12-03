# Interface for states
extends Node

func enter(host: PlayerPhysics):
	return

func step(host: PlayerPhysics, delta: float):
	return

func exit(host: PlayerPhysics, next_state:String):
	return

func animation_step(host: PlayerPhysics, animator: CharacterAnimator):
	return

func _on_animation_finished(anim_name: String):
	pass
