# Interface for states
extends Node

class_name State

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

func get_class():
	return "State"

func is_class(name:String):
	return get_class() == name || .is_class(name)
