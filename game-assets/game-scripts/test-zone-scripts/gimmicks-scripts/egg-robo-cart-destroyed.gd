extends Node2D
tool

export var linear_velocity : Vector2 = Vector2.ZERO setget set_linear_velocity


func _ready():
	pass


func set_linear_velocity(val : Vector2) -> void:
	linear_velocity = val
	for rb in get_children():
		var child : RigidBody2D = rb
		child.set_linear_velocity(val)
		child.linear_velocity.x += child.gravity_scale*100


func _on_VisibilityNotifier2D_screen_exited(val : String) -> void:
	get_node(val).queue_free()
	if get_child_count() <= 0:
		queue_free()
