tool
extends Node2D

export var direction:int = 0 setget setRot, getRot;
export var push_force = 500;
onready var sprite = $Sprite;
onready var jump_collide = $Body/JumpArea/JumpCollide
onready var left_spot = $SpotLeft;
onready var right_spot = $SpotRight;
onready var player = $"../../Player";
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
	if body.name == "Player":
		var abs_rot:float = abs(fmod(rotation_degrees, 360))
		animplayer.play("Push", -1, 2);
		body.audio_player.play('spring');
		if abs_rot == 0:
			body.has_pushed = true;
			var ground_angle = body.ground_angle();
			body.velocity.x -= push_force * sin(ground_angle);
			body.velocity.y -= push_force * cos(ground_angle);
			body.rotation_degrees = 0
			body.is_grounded = false
			body.has_jumped = false
			body.has_pushed = true
			body.fsm.change_state('OnAir');
		elif abs_rot == 90 || abs_rot == 270:
			if body.is_grounded:
				body.gsp = push_force*1.5 * sin(rotation);
			else:
				body.velocity.x = push_force*1.5 * sin(rotation);

func _on_AnimationPlayer_animation_finished(anim_name):
	animplayer.play("Stop");


func _on_ActivateArea_body_entered(body):
	jump_collide.set_deferred("disabled", false);


func _on_ActivateArea_body_exited(body):
	jump_collide.set_deferred("disabled", true)
