tool
extends StaticNode2D

func _ready() -> void:
	rotation_degrees = floor(rotation_degrees)

func _on_Damage_body_entered(body: Node) -> void:
	if body.is_class("PlayerPhysics"):
		var player : PlayerPhysics = body
		#print(player.speed, player.gsp)
		match rotation_degrees / 90:
			0.0:
				if !player.speed.y > 0 or player.is_grounded:
					pass
			1.0:
				if !player.speed.x < 0 || !player.direction.x < 0:
					return
			2.0:
				if !player.speed.y < 0:
					return
			3.0:
				if !player.speed.x > 0 || !player.direction.x > 0:
					return
		var direction = Vector2.ZERO
		direction.x = -player.characters.scale.x * cos(player.ground_angle())
		direction.y = -cos(player.ground_angle())
		direction = direction.sign()
		if !player.is_grounded:
			direction = global_position.direction_to(player.global_position).sign()
		player.damage(direction)


func _on_Damage_stay_inside(body : Node):
	if !body:
		return
	_on_Damage_body_entered(body)
