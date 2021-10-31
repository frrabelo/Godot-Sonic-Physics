extends TextureButton
tool

export(String) var text setget _set_text
var text_node = get_node_or_null("./main/Label")
onready var label = $main/Label
onready var anim_player : AnimationPlayer = $MainAnimator
onready var scroll_container : Container = get_parent()
var focused : bool = false

func _enter_tree():
	update()
	if text_node:
		text_node.set_text(text)
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
	if label:
		label.set_text(text)
	if Engine.editor_hint || !scroll_container:
		set_process(false)

func set_disabled(val: bool) -> void:
	.set_disabled(val)
	if disabled:
		anim_player.play("default")
		modulate = Color(0.5, 0.5, 0.5, 1.0)
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)

func _set_text(val : String):
	if val.length() <= 11:
		text = val
		if Engine.editor_hint:
			if text_node == null:
				text_node = get_node_or_null(@"./main/Label")
			else:
				text_node.text = text
		else:
			if label != null:
				label.set_text(text)
			else:
				label = get_node(@"main/Label")

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
	if disabled:
		return
	if scroll_container:
		var pos_in_parent = get_position_in_parent()
		if scroll_container.selected == pos_in_parent:
			scroll_container.select_mode(self)
			return
		scroll_container.selected = pos_in_parent
