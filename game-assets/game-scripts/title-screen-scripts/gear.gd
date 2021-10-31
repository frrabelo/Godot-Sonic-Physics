extends Node2D
tool

export var rpm : float = 5.0

func _enter_tree():
	set_process(!Engine.editor_hint)
	if rpm == 0:
		set_process(false)

func _ready():
	set_process(!Engine.editor_hint)
	if rpm == 0:
		set_process(false)

func _process(delta):
	rotation += rpm * delta/60
	rotation = fmod(rotation, TAU)
