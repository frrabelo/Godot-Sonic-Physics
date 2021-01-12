extends Area2D

export(bool) var rotate_cam;



func _on_RotateCamTrigger_body_entered(body):
	if body.is_class("PlayerPhysics"):
		var player_cam:PlayerCamera = $"/root/main/PlayerCamera"
		player_cam.rotateWithPlayer = rotate_cam
