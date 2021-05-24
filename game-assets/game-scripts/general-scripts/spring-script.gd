tool
extends StaticNode2D

export var push_force = 500;
onready var sprite = $Sprite;
onready var jump_collide = $Body/JumpArea/JumpCollide
onready var animplayer:AnimationPlayer = $Sprite/AnimationPlayer
signal pushed_by_spring

func _ready():
	rotation_degrees = floor(rotation_degrees);

func _on_JumpArea_body_entered(body):
	if body is PlayerPhysics:
		var player:PlayerPhysics = body;
		var abs_rot:float = abs(rotation_n)
		animplayer.play("Push", -1, 2);
		player.audio_player.play('spring');
		#var ground_angle = player.ground_angle();
		var vel : float = -push_force * cos(rotation);
		player.velocity.y = vel
		if abs_rot == 0 or abs_rot == 2:
			if player.is_grounded:
				player.snap_margin = 0
				player.is_grounded = false
				player.has_jumped = false
				player.is_floating = false
				player.fsm.change_state("OnAir")
			player.rotation = 0
			player.has_pushed = true
		elif abs_rot == 1 or abs_rot == 3:
			if player.is_grounded:
				match player.ground_mode:
					0:
						player.gsp = push_force*1.5 * sin(rotation);
					_:
						if abs(player.ground_mode) == 1:
							player.velocity.x = push_force * -player.ground_mode;
							player.position.x += player.velocity.x * get_physics_process_delta_time()
							player.velocity.y = 0;
						player.is_grounded = false;
						player.fsm.change_state("OnAir")
			else:
				player.velocity.x = push_force*1.5 * sin(rotation);

func _on_AnimationPlayer_animation_finished(anim_name):
	animplayer.play("Stop");


func _on_ActivateArea_body_entered(player):
	jump_collide.set_deferred("disabled", false);


func _on_ActivateArea_body_exited(player):
	jump_collide.set_deferred("disabled", true)
