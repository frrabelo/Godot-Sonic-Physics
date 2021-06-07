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
	if body.is_class("PlayerPhysics"):
		player = body;
		if player.is_grounded:
			player.is_grounded = false;
			player.snap_margin = 0
			#player.fsm.change_state("OnAir");
			player.speed.y = -100
			player.speed = player.move_and_slide(player.speed)
		player.rotation = 0
		player.has_jumped = false;
		player.spring_loaded = false;
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
			player.snap_margin = 0
			if player.is_grounded:
				player.is_grounded = false
				player.speed.y = -25
			if player.speed.y > -100:
				player.speed.y -= 25
			else:
				player.speed.y = -100
			player.is_grounded = false;
		if anim.get_playing_speed() < 5:
			anim.playback_speed += 0.1;
	else:
		if anim.get_playing_speed() > 0.1:
			anim.playback_speed -= 0.05;
		else:
			anim.stop(false);
			set_process(false);
