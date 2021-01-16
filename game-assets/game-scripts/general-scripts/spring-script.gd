tool
extends Node2D

export var direction:int = 0 setget setRot, getRot;
export var push_force = 500;
onready var sprite = $Sprite;
onready var jump_collide = $Body/JumpArea/JumpCollide
onready var animplayer:AnimationPlayer = $Sprite/AnimationPlayer
signal pushed_by_spring

func _ready():
	rotation_degrees = floor(rotation_degrees);

func setRot(value:int):
	direction = value%4
	rotation_degrees = [0, 90, 180, 270][direction];

func getRot():
	return direction;

func _on_JumpArea_body_entered(body):
	if body is PlayerPhysics:
		var player:PlayerPhysics = body;
		var abs_rot:float = abs(fmod(rotation_degrees, 360))
		animplayer.play("Push", -1, 2);
		player.audio_player.play('spring');
		var ground_angle = player.ground_angle();
		if abs_rot == 0 || abs_rot == 180:
			player.has_pushed = true;
			player.velocity.x -= push_force * sin(rotation);
			player.velocity.y -= push_force * cos(rotation);
			player.rotation_degrees = 0
			player.is_grounded = false
			player.has_jumped = false
			player.has_pushed = true
			player.fsm.change_state('OnAir');
		elif abs_rot == 90 || abs_rot == 270:
			print(player.ground_mode)
			if player.is_grounded:
				if player.ground_mode == 0:
					player.gsp = push_force*1.5 * sin(rotation);
				else:
					if abs(player.ground_mode) == 1:
						player.velocity.x = push_force * -player.ground_mode;
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
