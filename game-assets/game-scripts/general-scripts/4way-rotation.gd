extends Node2D
class_name StaticNode2D

export var rotation_n : int = 0 setget _set_rot_n

func _set_rot_n(val : int) -> void:
	if val < 0:
		val = 3
	val = abs(val % 4)
	rotation_n = val
	set_rotation_degrees(floor(90 * val))
