extends Node2D

onready var vp : Viewport = get_viewport()
export var curve : Curve
export var speed : float =0.05
export var pos : float = 0.0

func _ready():
	pass

func _process(delta):
	position.x = curve._data.
