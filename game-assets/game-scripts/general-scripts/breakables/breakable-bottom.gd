extends Breakable

onready var positions:Node2D = $Positions
var player : PlayerPhysics

func _on_Trigger_body_entered(body: Node) -> void:
	if body.is_class('PlayerPhysics'):
		player = body
		if player.speed.y > 0 || !player.fsm.is_current_state('OnAir'):
			return
		var speed = body.speed.y
		global_sounds.play('CliffBreaking')
		global_sounds.play('WallBreak')
		for i in positions.get_children():
			var p : Vector2 = i.position
			var spy = speed * -cos(positions.position.angle_to(p))
			var spx = speed/2 * sin(positions.position.angle_to(p))
			spawnBlock(p - Vector2(0, -16), Vector2(spx, spy), body)
			queue_free()
