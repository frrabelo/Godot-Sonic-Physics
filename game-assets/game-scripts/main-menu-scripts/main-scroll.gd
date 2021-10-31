extends ScrollContainer

var selected = 0 setget _set_selected
export(NodePath) var vb_container_path
onready var vb_container:Container = get_node(vb_container_path)
onready var tween_animation : Tween = $Tween
onready var global_sounds : AudioPlayer = get_node("/root/GlobalSounds")
onready var all_buttons : Array = Utils.get_nodes_by_type(vb_container, "TextureButton")
var all_disabled:bool = false

func _ready():
	var scroll_v_max = max(0, vb_container.rect_size.y - rect_size.y)
	#print(scroll_v_max)
	if scroll_v_max > 0:
		scroll_vertical = vb_container.get_child(selected).get_index() / scroll_v_max
	set_process_unhandled_key_input(false)
	margin_bottom = -(vb_container.get_child_count()*10)*2

func _set_selected(val : int) -> void:
	var length = vb_container.get_child_count()-1
	val = max(0, min(length, val))
	if val == selected || all_disabled:
		return
	while vb_container.get_child(val).disabled:
		val += (-sign(selected-val))
		if val < 0 || val >= length:
			return
	vb_container.get_child(selected).anim_player.play("reset")
	selected = max(0, min(val, length))
	vb_container.get_child(selected).anim_player.play("click")
	var scroll_v_max = max(0, vb_container.rect_size.y - rect_size.y)
	var total_button = vb_container.get_child_count()
	var vb_separation : int = vb_container.get_constant("separation")
	var vb_child : TextureButton = vb_container.get_child(selected)
	var step = ((selected) * (vb_separation + vb_child.rect_size.y))
	var final_value = min(scroll_v_max, max(0, step))
	scroll_vertical
	if tween_animation.is_active():
		tween_animation.stop_all()
	tween_animation.interpolate_property(self, @"scroll_vertical", scroll_vertical, final_value, 0.2, Tween.TRANS_QUAD)
	tween_animation.start()
	global_sounds.play("MenuBleep")
	#print(scroll_vertical)

func _input(event):
	if event.is_pressed():
		if event.is_action_pressed("ui_down") || event.is_action_pressed("ui_up"):
			var updown_strength = -event.get_action_strength("ui_up") + event.get_action_strength("ui_down")
			_set_selected(selected + updown_strength)
		if event.is_action_pressed("ui_jump"):
			select_mode(vb_container.get_child(selected))

func disable_buttons():
	for i in all_buttons:
		pass
		i.disabled = true
	all_disabled = true

func select_mode(button : TextureButton):
	if all_disabled:
		return
	button.anim_player.play("blinkLabel")
	global_sounds.play("MenuAccept")
	disable_buttons()

func _notification(what):
	match what:
		NOTIFICATION_SORT_CHILDREN:
			pass
