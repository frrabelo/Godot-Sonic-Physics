extends CanvasItem
tool

enum AXIS {X, Y}

export(AXIS) var axis
export var position : float = 0.0 setget _set_edit_position

func _ready() -> void:
	update()

func _set_edit_position(val : float) -> void:
	position = val
	update()



func _init() -> void:
	pass

func get_class() -> String:
	return "Node1D"

func is_class(name:String) -> bool:
	return get_class() == name || .is_class(name)
