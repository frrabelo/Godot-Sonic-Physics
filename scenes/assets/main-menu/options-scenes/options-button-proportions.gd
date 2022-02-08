extends OptionSelButton
tool

export(String) var option_values : String = "16:9"
var max_multiply = 50
var min_multiply = 30

func _process(delta):
	update()

func _draw():
	set_all()
	if !get_parent().is_class("ButtonSelector"):
		return
	var name_size = option_name_rect.texture.get_size()
	var name_text = option_name_rect.rect_position + name_size / 2
	name_text.x -= option_name.length() * (name_size.x / 13)/2 + 10
	name_text.y += name_text.y/2
	draw_string(get_parent().font, name_text, option_name, Color.white)
	
	var sep_text = option_values.split(":")
	var w = int(sep_text[0])
	var h = int(sep_text[1])
	var selected_value_m = (selected_value + 3) * 10
	var value_size = option_values_rect.get_parent().rect_size
	var value_text = option_values_rect.get_parent().rect_position + option_values_rect.rect_position + value_size / 2
	value_text.x -= option_values[selected_value].length() * (value_size.x / 13) / 2 + 20
	value_text.y += value_text.y/2
	draw_string(get_parent().font, value_text, "%dx%d" % [w *selected_value_m, w * selected_value_m], Color.white)

func set_option_value(val : String) -> void:
	set_all()
	option_values = val
	update()

func set_selected_value(val : int) -> void:
	set_all()
	selected_value = min(8, max(1, val))
	update()
