extends ParallaxBackground

onready var player_camera = $"/root/main/PlayerCamera";

func _ready():
	set_process(false)

func _process(delta):
	if player_camera:
		transform.origin.x = player_camera.position.x
		transform.origin.y = player_camera.position.y - 150
