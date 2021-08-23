tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("Node1D", "CanvasItem", preload('res://addons/Node1D/Node1D.gd'), preload('res://addons/Node1D/node1d.svg'))
	pass

func _exit_tree() -> void:
	remove_custom_type('Node1D')
	pass
