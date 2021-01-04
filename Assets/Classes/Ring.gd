extends Node2D

var blink = preload("res://Assets/General Objects/RingBlink.tscn");
var instBlink:Node2D = blink.instance();
export(int) var points = 1;

func _on_Area_body_entered(body):
	if body.name == "Player":
		queue_free()
		$"/root/main".ring += 1;
		var player:PlayerPhysics = body as PlayerPhysics
		var sound:AudioPlayer = player.get_node("AudioPlayer");
		instBlink.position = position;
		instBlink.animation = floor(rand_range(0, 3));
		var instBlinkAnim:AnimatedSprite = instBlink.get_node("Anim")
		get_parent().add_child(instBlink);
		sound.play("ring");
		queue_free();

