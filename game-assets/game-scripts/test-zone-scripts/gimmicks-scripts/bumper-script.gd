extends Area2D

onready var anim_player : AnimationPlayer = $AnimationPlayer
onready var audio_player : AudioStreamPlayer2D = $Bump

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_class('PlayerPhysics'):
		var p : PlayerPhysics = body
		var angle : float = position.angle_to_point(p.position)
		var min_speed = 340.0
		p.speed.x = -max(abs(p.speed.x), min_speed) * cos(angle)
		p.speed.y = max(abs(p.speed.y), min_speed) * -sin(angle)
		anim_player.play('Bump')
		audio_player.play()
		#print(p.speed)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		'Bump':
			anim_player.seek(0)
