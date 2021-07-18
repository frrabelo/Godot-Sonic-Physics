extends AnimationPlayer

class_name CharacterAnimator

var previous_animation : String
var previous_anim_back : bool

func animate(animation_name : String, custom_speed : float, can_loop : bool):
	if can_loop and animation_name == previous_animation and !previous_anim_back:
		return
	
	play(animation_name, -1, custom_speed)
	previous_animation = animation_name
	previous_anim_back = false
	

func animate_from_end(animation_name : String, custom_speed : float, can_loop : bool):
	if can_loop and animation_name == previous_animation and previous_anim_back:
		return
	
	play(animation_name, -1, custom_speed, true)
	previous_animation = animation_name
	previous_anim_back = true
