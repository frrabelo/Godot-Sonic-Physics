extends Node2D
tool
class_name ObjectSpawner

export var scene : PackedScene = preload("res://general-objects/ring-object.tscn")
var path : Path2D
export var update:bool setget _update_button
export var offset:Vector2 = Vector2(8, 8)

func _enter_tree() -> void:
	if Engine.editor_hint:
		update_configuration_warning()
		update_objects()

func update_objects() -> void:
	if !path || !scene:
		return
	if path.get_child_count() > 0:
		for i in path.get_children():
			i.queue_free()
	var curves = path.curve.get_baked_points()
	for i in curves:
		var obj = scene.instance()
		obj.position = i + offset
		var container = Node2D.new()
		path.add_child(container)
		container.add_child(obj)

func _get_configuration_warning() -> String:
	var to_return = ""
	path = Utils.get_node_by_type(self, "Path2D")
	if !path:
		to_return += "ObjectSpawner must contain a Path2D as a child"
	if !scene:
		if !path:
			to_return += "\n"
		to_return += "ObjectSpawner must have a PackedScene to instance"
	
	return to_return

func _update_button(val : bool) -> void:
	update_objects()
