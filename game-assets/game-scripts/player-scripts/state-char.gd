extends Node

onready var character = get_parent().get_parent()

class_name StateChar

func enter(host: PlayerPhysics, prev_state:String, main_state:State):
	return

func step(host: PlayerPhysics, delta: float, main_state:State):
	return

func exit(host: PlayerPhysics, next_state:String, main_state:State):
	return

func animation_step(host: PlayerPhysics, animator: CharacterAnimator, main_state:State, args:Array = []):
	return


func _on_animation_finished(anim_name: String):
	pass

func get_class():
	return "StateChar"

func is_class(name:String):
	return get_class() == name || .is_class(name)
