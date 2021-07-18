extends Node

onready var character = get_parent().get_parent()

class_name StateChar

func enter(host: PlayerPhysics, prev_state:String, main_state:State = null):
	return

func step(host: PlayerPhysics, delta: float, main_state:State = null):
	return

func exit(host: PlayerPhysics, next_state:String, main_state:State = null):
	return

func animation_step(host: PlayerPhysics, animator: CharacterAnimator, delta : float, main_state:State = null, args:Array = []):
	return

func state_input(host : PlayerPhysics, event: InputEvent, main_state:State = null):pass

func _on_animation_finished(anim_name: String):
	pass

func get_class():
	return "StateChar"

func is_class(name:String):
	return get_class() == name || .is_class(name)
