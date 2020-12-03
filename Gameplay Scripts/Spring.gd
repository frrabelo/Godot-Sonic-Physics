extends Node2D

export var jump_height = -500;
onready var sprite = $Body/Sprite;
onready var animplayer:AnimationPlayer = sprite.get_node("AnimationPlayer");

signal pushed_by_spring

func _on_Area_body_entered(body):
	if body.name == "Player":
		if body.fsm.current_state == 'OnGround':
			connect(\
				"pushed_by_spring",\
				body.fsm.states["OnGround"],\
				"when_pushed_by_spring",\
				[self]
			);
			emit_signal("pushed_by_spring");
			animplayer.play("Push", -1, 2);
			var ground_angle = body.ground_angle();
			body.velocity.x -= body.JMP * sin(ground_angle)
			body.velocity.y -= body.JMP * cos(ground_angle)
			body.velocity.x -= jump_height * sin(ground_angle);
			body.velocity.y -= jump_height * cos(ground_angle);
			body.rotation_degrees = 0
			body.is_grounded = false
			body.has_jumped = false
			body.has_pushed = true
			body.audio_player.play('spring');
			body.fsm.change_state('OnAir');


func _on_AnimationPlayer_animation_finished(anim_name):
	animplayer.play("Stop");
