extends Breakable
var min_speed = 250;
onready var hitBox = $"Body/HitBox"

func _on_BreakArea_body_entered(body):

	if body.is_class("PlayerPhysics"):
		#print("e")
		var player:PlayerPhysics = body
		if player.is_grounded:
			if player.is_rolling:
				#print("e")
				if abs(player.gsp) > min_speed:
					global_sounds.play('WallBreak')
					global_sounds.play('CliffBreaking')
					var speed:Vector2
					speed = player.speed
					for i in range(0, 3):
						for j in 2:
							speed.x += j * 20
							speed.y += (i+1) * 20
							spawnBlock(\
								Vector2([-8, 8][j], [-22, 0, 22][i]),\
								speed,\
								player
							)
					queue_free()
					
