extends Node
onready var state_machine = get_parent()
class_name State
func enter(host: PlayerPhysics, prev_state:String):
	pass
func step(host: PlayerPhysics, delta: float):
	pass
func exit(host: PlayerPhysics, next_state:String):
	pass

func animation_step(host: PlayerPhysics, animator: CharacterAnimator, delta:float):
	pass

func _on_animation_finished(host:PlayerPhysics, anim_name: String):
	pass

func state_input (host : PlayerPhysics, event : InputEvent):pass

func get_class():
	return "State"

func is_class(name:String):
	return get_class() == name || .is_class(name)
