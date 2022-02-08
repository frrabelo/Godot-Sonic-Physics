extends ColorRect
tool

export(Color) var base_color
export(int, 0, 100, 1) var hue:int = 0 setget _set_hue

func _set_hue(val:int) -> void:
	hue = max(0, min(100, val))
	color = base_color
	color.h = float(hue)/100 + base_color.h
	var c = get_child_count()
	if c > 0:
		for i in get_child(0).get_children():
			i.get_child(0).default_color = i.get_child(0).base_color
			i.get_child(0).default_color.h = i.get_child(0).base_color.h + float(hue)/100
			for j in i.get_child(0).get_children():
				j.update()
