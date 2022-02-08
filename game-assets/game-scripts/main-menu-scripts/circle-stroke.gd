extends Node2D
tool

var nodes = []
export var erase : bool setget _erase

func _ready():
	position = Vector2.ZERO
	set_process(!Engine.editor_hint)

func _draw():
	if nodes.size() > 0:
		for i in nodes:
			draw_circle(i.position, i.radius + i.stroke, i.band.default_color)

func append_to_stroke(_node:Node):
	nodes.append(_node)
	update()

func _process(delta):
	update()

func _erase(val : bool):
	nodes = []
