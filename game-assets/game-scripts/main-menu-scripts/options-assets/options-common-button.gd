extends OptionSelButton
tool

onready var name_player : AnimationPlayer = get_node("NamePlayer")
onready var value_player : AnimationPlayer = get_node("ValuePlayer")
onready var all_player : AnimationPlayer = get_node("AllPlayer")

func _process(delta):
	update()

func on_value_change():
	value_player.play("RESET")
	value_player.play("click")

func _notification(what):
	var min_rect : Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)
	for i in get_children():
		if !i is HBoxContainer:
			return
		var hbox : HBoxContainer = i
		min_rect.size.x = max(min_rect.size.x, hbox.rect_size.x+hbox.rect_position.x)
		min_rect.size.y = max(min_rect.size.y, hbox.rect_size.y+hbox.rect_position.y)
	
	rect_min_size = min_rect.size

func _draw():
	set_all()
	draw_text_option_name()
	if !get_parent().is_class("ButtonSelector"):
		return
	if option_values.size() <= 0:
		return
	var value_size = option_values_rect.get_parent().rect_size
	var value_position = option_values_rect.get_parent().rect_position
	var selected_option_value = option_values[current_value]
	
	var value_position_with_offset = option_values_rect.get_rect().position + value_position + value_size / 2
	if selected_option_value is String:
		value_position_with_offset.x -= option_values[current_value].length() * (value_size.x / 13) / 2 + 20
		value_position_with_offset.y += value_position.y/2
	elif selected_option_value is Image:
		value_position_with_offset.x -= value_position.x / 2
		value_position_with_offset.y -= value_position.y/2
	var selected_option_val_is_string = selected_option_value is String
	var selected_option_val_is_texture = selected_option_value is Texture
	{
		selected_option_val_is_string: funcref(self, "draw_text_option_value"),
		selected_option_val_is_texture: funcref(self, "draw_texture_option")
	}[true].call_func(value_size, value_position_with_offset)

func draw_text_option_name():
	var name_size = option_name_rect.texture.get_size()
	var name_text = option_name_rect.rect_position + name_size / 2
	name_text.x -= option_name.length() * (name_size.x / 13)/2 + 10
	name_text.y += name_text.y/2
	draw_string(get_parent().font, name_text, option_name, Color.white)

func draw_text_option_value(value_size:Vector2, value_position:Vector2):
	draw_string(get_parent().font, value_position, option_values[current_value], Color.white)

func draw_texture_option(value_size:Vector2, value_position: Vector2):
	var img : StreamTexture = option_values[current_value] as StreamTexture
	var img_size = Utils.clamp_vector2(img.get_size(), Vector2.ZERO, Vector2(value_size.x, value_size.x))
	draw_texture_rect(option_values[current_value], Rect2(value_position - img_size/2, img_size), false)

func set_current_value(val : int) -> void:
	if option_values.size() <= 0:
		return
	if val < 0:
		current_value = option_values.size() - 1
	current_value = val % option_values.size()


func set_option_values(val : Array) -> void:
	option_values = val
