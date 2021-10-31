extends VBoxContainer

onready var sc = get_parent()
func _ready():
	set_as_toplevel(true)
	set_process(true)

func _process(delta):
	rect_global_position.x = sc.rect_global_position.x
	rect_global_position.y = sc.rect_global_position.y + sc.scroll_vertical
