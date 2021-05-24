tool
extends StaticNode2D

func _ready() -> void:
	rotation_degrees = floor(rotation_degrees)


func _on_Damage_body_entered(body: Node) -> void:
	if body.is_class("PlayerPhysics"):
		var player : PlayerPhysics = body
		var direction = global_position.direction_to(player.global_position).sign()
		print(player.velocity, player.gsp)
		match rotation_n:
			0:
				if !player.velocity.y > 0 && !player.is_grounded:
					return
			1:
				if !player.velocity.x < 0 && !player.direction.x < 0:
					return
			2:
				if !player.velocity.y < 0:
					return
			3:
				if !player.velocity.x > 0 && !player.direction.x > 0:
					return
		player.damage(direction)
