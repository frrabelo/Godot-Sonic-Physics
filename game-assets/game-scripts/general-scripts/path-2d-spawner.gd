extends Path2D
tool
class_name Path2DSpawner

var parent_is_obj_spawner : bool = false

func _enter_tree() -> void:
	update_configuration_warning()

func set_curve(val : Curve2D) -> void:
	if parent_is_obj_spawner:
		get_parent().update_objects()

func _draw() -> void:
	if parent_is_obj_spawner:
		get_parent().update_objects()

func _get_configuration_warning() -> String:
	var to_return := ""
	if !get_parent() is ObjectSpawner:
		to_return = "Path2DSpawner must contain ObjectSpawner as a parent"
	else:
		parent_is_obj_spawner = true
	return to_return
