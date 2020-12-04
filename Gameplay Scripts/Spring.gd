extends Node2D

export var push_force = -500;
onready var sprite = $Body/Sprite;
onready var animplayer:AnimationPlayer = sprite.get_node("AnimationPlayer");
signal pushed_by_spring

func _ready():
	rotation_degrees = floor(rotation_degrees)

func _on_Area_body_entered(body):
	if body.name == "Player":
		print (rotation_degrees)
		if true:
			animplayer.play("Push", -1, 2);
			body.audio_player.play('spring');
			if rotation_degrees == 0:
				connect(\
					"pushed_by_spring",\
					body.fsm.states["OnGround"],\
					"when_pushed_by_spring",\
				[self]
				);
				emit_signal("pushed_by_spring");
				var ground_angle = body.ground_angle();
				body.velocity.x -= push_force * sin(ground_angle);
				body.velocity.y -= push_force * cos(ground_angle);
				body.rotation_degrees = 0
				body.is_grounded = false
				body.has_jumped = false
				body.has_pushed = true
				print ("aaaa");
				body.fsm.change_state('OnAir');
			elif rotation_degrees == 90 || rotation_degrees == 270:
				if body.is_grounded:
					body.gsp = push_force*1.5 * sin(rotation);
				else:
					body.velocity.x = push_force*1.5 * sin(rotation);


func _on_AnimationPlayer_animation_finished(anim_name):
	animplayer.play("Stop");
