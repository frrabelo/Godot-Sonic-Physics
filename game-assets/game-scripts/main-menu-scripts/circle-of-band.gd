extends Node2D
tool

var band : Line2D = get_parent()
export var radius = 20.0 setget _set_radius
export var stroke = 2.0 setget _set_stroke
export var editor_process : bool = false setget _set_editor_process
export var init_pos : float = 1.0 setget _set_init_pos
var moving:float
export var speed : float = 2.0

func _ready():
	get_parent().get_node_or_null("Stroke").append_to_stroke(self)
	if Engine.editor_hint:
		band = get_parent()
		set_process(editor_process && band.editor_process)
	else:
		band = get_parent()
		moving = (band.points.size()-1)*init_pos
		position = band.points[moving]
		set_process(band.is_processing())

func _process(delta):
	var size = band.get_size().x
	moving -= speed * delta
	var points = band.get_points()
	var top = points[ceil(moving)]
	var bottom = points[floor(moving)]
	var top_f = moving-floor(moving)
	if floor(moving) <= 0 && moving < 0.1:
		top = points[0]
		top_f = 0
	if moving <= 0:
		moving = points.size()-1
	position = top_f * top + (1.0-top_f) * bottom

func _draw():
	if !(get_parent().get_node_or_null("Stroke").nodes as Array).has(self):
		get_parent().get_node_or_null("Stroke").append_to_stroke(self)
	draw_circle(Vector2.ZERO, radius, get_parent().get_parent().get_parent().get_parent().color)
	position = band.get_points()[round((band.points.size()-1)*init_pos)]

func _set_radius(val : float) -> void:
	radius = val
	update()

func _set_stroke(val : float) -> void:
	stroke = val
	update()

func _set_init_pos(val : float) -> void:
	init_pos = max(0.0, min(1.0, val))
	update()

func _set_editor_process(val : bool) -> void:
	editor_process = val
	if Engine.editor_hint:
		if !band:
			band = get_parent()
		else:
			set_process(editor_process && band.editor_process)
