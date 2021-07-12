extends Path2D
tool
class_name ObjectSpawnerArc

export var scene : PackedScene = preload("res://general-objects/ring-object.tscn")
export var update:bool setget _update_button
export var offset:Vector2 = Vector2(8, 8)

func _ready() -> void:
	refresh()

func refresh () -> void:
	if get_child_count() > 0:
		for i in get_children():
			i.queue_free()
	var curves = curve.get_baked_points()
	for i in curves:
		var obj = scene.instance()
		obj.position = i + offset
		var container = Node2D.new()
		add_child(container)
		container.add_child(obj)

func _draw() -> void:
	refresh()

func _update_button(val : bool) -> void:
	refresh()
