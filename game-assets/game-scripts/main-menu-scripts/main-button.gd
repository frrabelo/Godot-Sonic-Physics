extends TextureButton
class_name MenuMainButton
tool

enum ACTIONS {
	LOAD_SCENE,
	CALL_FUNCTION
}

export(String) var text setget _set_text
export(ACTIONS) var action_type = ACTIONS.LOAD_SCENE
export(String) var action
export(Array, String) var action_args = []
export(bool) var clickable = true
onready var anim_player : AnimationPlayer = $MainAnimator
export var scroll_container_path : NodePath = get_path_to(get_parent())
onready var scroll_container : Container = Utils.get_parent_by_type(self, "ButtonSelector", 4)

func _enter_tree():
	update()
	if Engine.editor_hint:
		set_process(false)

func _ready():
	connect('pressed', self, "_on_MainButton_pressed")
	connect("mouse_entered", self, "_on_MainButton_mouse_entered")
	connect("mouse_exited", self, "_on_MainButton_mouse_exited")
	set_disabled(disabled)
	update()
	if scroll_container:
		if "selected" in scroll_container && scroll_container.selected == get_position_in_parent():
			anim_player.play("hover")

func set_disabled(val: bool) -> void:
	.set_disabled(val)
	if disabled:
		anim_player.play("default")
		modulate = Color(0.5, 0.5, 0.5, 1.0)
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_MainButton_mouse_entered():
	if disabled:
		return
	anim_player.play("hover")

func _on_MainButton_mouse_exited():
	if disabled:
		return
	if anim_player.current_animation != "default" && scroll_container.selected != get_position_in_parent():
		anim_player.play("reset")


func _on_MainButton_pressed():
	if disabled || !clickable:
		return
	if scroll_container:
		var pos_in_parent = get_position_in_parent()
		if scroll_container.selected == pos_in_parent:
			scroll_container.select_mode(self)
			return
		scroll_container.selected = pos_in_parent

func _set_text(val : String): pass
