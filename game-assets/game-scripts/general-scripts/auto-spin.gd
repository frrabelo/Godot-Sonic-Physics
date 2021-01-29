tool
extends Area2D

export var spin = true
export var impulse = true

func _on_AutoSpin_body_entered(body):
	if body.is_class("PlayerPhysics"):
		$CollisionShape2D.set_deferred("disabled", true)
		var player:PlayerPhysics = body
		if impulse:
			if !player.constant_roll:
				player.gsp += 300 * player.character.scale.x
		if spin:
			player.constant_roll = !player.constant_roll
			player.constant_roll = player.constant_roll


func _on_AutoSpin_body_exited(body):
	$CollisionShape2D.set_deferred("disabled", false)
