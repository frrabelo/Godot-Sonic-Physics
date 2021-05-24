extends KinematicBody2D
class_name Badnik

export var max_speed:Vector2 = Vector2(70,0);
var speed:Vector2 = max_speed;
export var to_right:bool = false;
export(String) var main_anim_name = "none";
export(float) var init_timer = 1;
var time:float = init_timer;
onready var explode_audio_player:AudioStreamPlayer = get_node("/root/main/GlobalSFX/Destroy")

func uselessSetter(useless_value):
	pass

func direction():
	return (-int(!to_right) + int(to_right));

func push_player(player:PlayerPhysics):
	var distance = global_position.direction_to(player.global_position).sign()
	player.damage(distance);
