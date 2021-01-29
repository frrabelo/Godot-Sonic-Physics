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
		player.is_grounded = false;
		player.fsm.change_state("OnAir");
		if player.velocity.y > -16:
			player.velocity.y += -16 * get_physics_process_delta_time();
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
			if player.is_grounded:
				player.is_grounded = false
				player.velocity.y = - 25
			if player.velocity.y > -100:
				player.velocity.y -= 25
			else:
				player.velocity.y = -100
			player.is_grounded = false;
		if anim.get_playing_speed() < 5:
			anim.playback_speed += 0.1;
	else:
		if anim.get_playing_speed() > 0.1:
			anim.playback_speed -= 0.05;
		else:
			anim.stop(false);
			set_process(false);
