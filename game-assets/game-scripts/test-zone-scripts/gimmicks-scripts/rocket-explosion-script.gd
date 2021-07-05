extends Node2D
class_name CircleVisualEffect
tool
export(float) var radius : float setget _set_radius
export(Color) var color : Color setget _set_color

func _set_radius (val : float) -> void:
	radius = val
	update()

func _set_color (val : Color) -> void:
	color = val
	update()

func _draw() -> void:
	if radius <= 0:
		return
	draw_circle(Vector2.ZERO, radius, color)
