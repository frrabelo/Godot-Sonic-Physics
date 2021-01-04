extends Node2D


func _ready():
	$DropDashDust/AnimationPlayer.play("DropDust", -1, 2);
	pass
func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
	pass
