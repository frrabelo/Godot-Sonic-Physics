extends Node2D
const bullet_scene = preload("res://Zones/TestZone/BulletImpulsor.tscn");

func _on_Area_body_entered(body):
	if body.name == "Player":
		var dir = -int(body.gsp < 0) + int(body.gsp>0)
		if body.is_grounded:
			spawnBullet(\
				Vector2((20 * -dir), -300),\
				Vector2(0, -5)\
			);
			var abs_gsp = abs(body.gsp)
			if abs_gsp < 700:
				body.gsp = 700 * dir
			elif abs_gsp < 1100:
				body.gsp += 150 * dir
			else:
				body.gsp = 1100 * dir

func spawnBullet(speed:Vector2, pos:Vector2):
	var bullet:Node2D = bullet_scene.instance();
	get_parent().add_child(bullet);
	bullet.speed = speed;
	bullet.position = global_position + pos
	bullet.set("spawnpoint", bullet.get("position"));
	bullet.sprite.rotate(rotation + (1 * int(rotation == 0)));
	bullet.sprite.scale.x = int(speed.x < 0) - int(speed.x > 0);
