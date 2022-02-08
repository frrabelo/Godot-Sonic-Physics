extends Control
tool

export var default_color:Color setget _set_default_color
export var z_index : int = 0 setget _set_z_index
export var pos : int = 0 setget _set_pos
export(float, -360, 360, 1) var width : float = 22.5 setget _set_width

func _ready():
	pass

func _draw():
	var rect : Rect2 = Rect2(rect_position, rect_size)
	var dang = deg2rad(width)
	var points:PoolVector2Array = [
		Vector2(0, 0),
		Vector2(rect.size.x+width, 0),
		Vector2(rect.size.x, rect.size.y),
		Vector2(-width, rect.size.y),
	]
	for i in points.size():
		points[i].y += pos + width
		points[i].x -= pos - width
	VisualServer.canvas_item_set_draw_index(get_canvas_item(), z_index)
	VisualServer.canvas_item_set_z_index(get_canvas_item(), z_index)
	draw_colored_polygon(points, default_color, [], null, null, true)

func _set_default_color(val : Color) -> void:
	default_color = val
	update()

func _set_z_index(val : int) -> void:
	z_index = val
	update()

func _set_pos(val : int) -> void:
	pos = val
	update()

func _set_width(val : float) -> void:
	width = val
	update()
