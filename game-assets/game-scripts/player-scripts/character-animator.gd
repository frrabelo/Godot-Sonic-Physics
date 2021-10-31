extends AnimationPlayer

class_name CharacterAnimator

var previous_animation : String
var previous_anim_back : bool

func _ready():
	connect("animation_finished", self, "_on_MainAnimator_animation_finished")

func animate(animation_name : String, custom_speed : float = 1.0, can_loop : bool = true):
	if can_loop and animation_name == previous_animation and !previous_anim_back:
		return
	
	play(animation_name, -1, custom_speed)
	previous_animation = animation_name
	previous_anim_back = false
	

func animate_from_end(animation_name : String, custom_speed : float = 1.0, can_loop : bool = true):
	if can_loop and animation_name == previous_animation and previous_anim_back:
		return
	
	play(animation_name, -1, custom_speed, true)
	previous_animation = animation_name
	previous_anim_back = true


func _on_MainAnimator_animation_finished(anim_name):
	previous_animation = anim_name
