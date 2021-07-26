extends Node
class_name ReadOnlyRect

var rect : Rect2
func get_rectshape_2d() -> Dictionary:
	var shape := RectangleShape2D.new();
	shape.extents = rect.size/2
	return {
		shape = shape,
		position = rect.position,
	}
