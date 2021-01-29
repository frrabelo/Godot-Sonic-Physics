tool
extends Node2D
var showTrigger:Area2D;
export(float) var trigger_position = 80 setget setTriggerPos, getTriggerPos;
export(float) var trigger_width = 80 setget setTriggerWidth, getTriggerWidth
var show_rect:RectangleShape2D = RectangleShape2D.new();
export var initial_angle : float = 180 setget setInitAngle, getInitAngle;
export var final_angle : float = 0 setget setFinalAngle, getFinalAngle;
var activate:bool = false;
var anim_player : AnimationPlayer;
var sp_plat : Node2D

func _ready():
	$SpPlat.rotation_degrees = initial_angle;
	if anim_player:
		anim_player.playback_speed = 5.0

func _enter_tree():
	_prepare();

func _prepare():
	setShowTrigger()
	show_rect.extents.y = 165
	set_physics_process(false)
	anim_player = $AnimationPlayer
	$ShowTrigger/CollisionTrigger.shape = show_rect;
	sp_plat = $SpPlat

func setInitAngle(value:float):
	initial_angle = fmod(value, 360);
	if sp_plat:
		sp_plat.rotation_degrees = initial_angle;
	if anim_player:
		anim_player.get_animation("FromAtoB").track_set_key_value(0, 0, value)
		print(anim_player.get_animation("FromAtoB").track_get_key_value(0, 0))

func getInitAngle():
	return initial_angle;

func setFinalAngle(value:float):
	final_angle = fmod(value, 360)
	if anim_player:
		anim_player.get_animation("FromAtoB").track_set_key_value(0, 1, final_angle)
		print(anim_player.get_animation("FromAtoB").track_get_key_value(0, 1))
	pass

func getFinalAngle():
	return final_angle

func setShowTrigger():
	if has_node("ShowTrigger"):
		showTrigger = $ShowTrigger;

func setTriggerPos(value: float):
	if showTrigger == null:
		setShowTrigger();
	if showTrigger != null:
		showTrigger.position.x = value;

func getTriggerPos():
	if showTrigger == null:
		setShowTrigger();
	if (showTrigger != null):
		return showTrigger.position.x;
	return 0;

func setTriggerWidth(value:float):
	show_rect.extents.x = value;

func getTriggerWidth():
	return show_rect.extents.x

func _on_ShowTrigger_body_entered(body):
	if body.is_class("PlayerPhysics"):
		anim_player.play("FromAtoB", -1)

func _on_ShowTrigger_body_exited(body):
	if body.is_class("PlayerPhysics"):
		anim_player.play_backwards("FromAtoB", -1)

func _on_RedSpringFromSolid_script_changed():
	_prepare();
