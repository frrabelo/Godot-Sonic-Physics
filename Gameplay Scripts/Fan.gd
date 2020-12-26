extends Node2D
var player:PlayerPhysics;
onready var anim = $Sprite/AnimationPlayer;
onready var start_trigger = $Trigger
var inside : bool = false;
func _ready ():
	if start_trigger != null:
		start_trigger.visible = false;
	set_process(false);

func _on_areaStart_body_entered(body):
	if body.name == "Player":
		player = body;
		player.is_grounded = false;
		player.fsm.change_state("OnAir");
		player.velocity.y -= 25;
		player.has_jumped = false;
		player.has_pushed = false;
		player.is_floating = true;
		anim.play("Rotating", -1, 1)
		inside = true
		set_process(true);

func _on_areaStart_body_exited(body):
	if body.name == "Player":
		inside = false

func _process(delta):
	if inside == true:
		if player != null:
			if player.velocity.y > -150:
				player.velocity.y -= 25;
			player.is_grounded = false;
		if anim.get_playing_speed() < 5:
			anim.playback_speed += 0.1;
	else:
		if anim.get_playing_speed() > 0:
			anim.playback_speed -= 0.1;
		else:
			anim.stop(false);
			set_process(false);
