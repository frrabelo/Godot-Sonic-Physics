extends Node2D

export var jump_height = -500;
onready var sprite = $Body/Sprite;
onready var animplayer:AnimationPlayer = sprite.get_node("AnimationPlayer");

signal pushed_by_spring

func _on_Area_body_entered(body):
	if body.name == "Player":
		connect(\
			"pushed_by_spring",\
			body.fsm.states["OnGround"],\
			"when_pushed_by_spring",\
			[self]
		);
		emit_signal("pushed_by_spring");
		animplayer.play("Push", -1, 2);
		body.velocity.y = jump_height;


func _on_AnimationPlayer_animation_finished(anim_name):
	animplayer.play("Stop");
