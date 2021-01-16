extends Node

onready var anim_player = $AnimationPlayer

func _ready():
	anim_player.play("Fade", -1, 1.0, false)
