extends Container
class_name ButtonSelector

export var value_back = "ui_left"
export var value_next = "ui_right"
export var selector_back = "ui_up"
export var selector_next = "ui_down"
onready var global_sounds : AudioPlayer = $"/root/GlobalSounds"
var selected = 0 setget _set_selected
var all_disabled:bool = false

func disable_buttons():
	for i in get_children():
		pass
		i.disabled = true
	all_disabled = true
	set_process(false)

func select_mode(button):
	if all_disabled:
		return
	button.anim_player.connect("animation_finished", self, "action_button", [button])
	button.anim_player.play("blinkLabel")
	global_sounds.play("MenuAccept")
	if button.action == "exit":
		var music_process = get_parent().get_owner().get_node("MusicProcess")
		music_process.queue_free()
	disable_buttons()

func action_button(anim_name, button):
	if anim_name != "blinkLabel":
		return
	match button.action_type:
		button.ACTIONS.LOAD_SCENE:
			get_parent().get_owner().load_scene(button.action)
		
		button.ACTIONS.CALL_FUNCTION:
			get_parent().call(button.action)

func _input(event):
	if event.is_action_pressed("ui_home"):
		get_parent().back()

func _set_selected(val):
	selected = val

func get_class():
	return "ButtonSelector"

func is_class(val : String) -> bool:
	return val == "ButtonSelector" || .is_class(val)
