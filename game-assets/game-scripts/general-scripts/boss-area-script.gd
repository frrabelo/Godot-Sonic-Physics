extends Area2D
var players = []
func _on_BossArea_body_shape_entered(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	if body.is_class("PlayerPhysics"):
		pass
		var p : PlayerPhysics = body
		if p.player_camera:
			var pc : PlayerCamera = p.player_camera
			pc.follow_player = false;
			players.append(p);
			pc.object_to_stuck = self
			pc.stuck_in_object = true

func _on_BossDied(boss) -> void:
	pass

func _reset_PlayerCamera() -> void:
	for i in players:
		i.player_camera.follow_player = true
		i.player_camera.object_to_stuck = null
		i.player_camera.stuck_in_object = false

func _on_BossArea_body_shape_exited(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	var has_boss = false
	for i in get_children():
		if i.is_class("Boss"):
			has_boss = true
			break;
	if !has_boss:
		_reset_PlayerCamera()
