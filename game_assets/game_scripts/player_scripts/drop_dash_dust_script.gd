extends Node2D

export var anim_name:String;

func _ready():
	$DropDashDust/AnimationPlayer.play(anim_name, -1, 2);
	pass
func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
	pass
