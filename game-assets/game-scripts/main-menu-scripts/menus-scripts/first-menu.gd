extends Control
class_name MainMenuScreen

export (int, 0, 100, 1)var hue_value = 0
var previous_path : String
export var initial : bool
export var main_scene_path : String
export var back_scene_path : String



func _update_owner(ownern:Node):
	owner = ownern
	ownern.update()

func exit():
	var fade = get_owner().get_node("Filter/Fade")
	var transition = get_owner().get_node("Top/Transition")
	transition.play("In")
	yield(transition, "animation_finished")
	fade.play("Fadeout")
	yield(fade, "animation_finished")
	get_tree().quit(0)

func back():
	if initial:
		get_owner().back_to_title_screen()
	else:
		if back_scene_path:
			get_owner().load_scene(back_scene_path)
			return
		get_owner().load_scene(previous_path)
