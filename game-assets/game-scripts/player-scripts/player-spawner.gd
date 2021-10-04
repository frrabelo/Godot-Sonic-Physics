extends Position2D
class_name PlayerSpawner
tool

func _draw():
	if !OS.is_debug_build():
		return
	var size:Vector2 = Vector2(14, 19)
	var points : PoolVector2Array = [
		Vector2(-size.x, -size.y),
		Vector2(-size.x, size.y/2),
		Vector2(0, size.y+1),
		Vector2(size.x, size.y/2),
		Vector2(size.x, -size.y),
	]
	draw_colored_polygon(points, Color(0, 0.5, 0.7, 0.5))
	draw_polyline(points, Color(0, 0.7, 0.5, 0.5), 2.0)
