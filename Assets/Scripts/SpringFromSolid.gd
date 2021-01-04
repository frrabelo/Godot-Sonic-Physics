tool
extends Node2D
var showTrigger:Area2D;
var hideTriggerB:Area2D;
var hideTriggerT:Area2D;
export(float) var trigger_position = 80 setget setTriggerPos, getTriggerPos;
export(float) var trigger_width = 80 setget setTriggerWidth, getTriggerWidth
var rect:RectangleShape2D = RectangleShape2D.new();
var show_rect:RectangleShape2D = RectangleShape2D.new();

func _ready():
	$AnimationPlayer.play("Normal", -1, 0);

func _enter_tree():
	_prepare();

func _prepare():
	setShowTrigger()
	show_rect.extents.y = 90
	rect.extents.y = 3
	$ShowTrigger/CollisionTrigger.shape = show_rect;
	$HideTriggerTop/CollisionTrigger.shape = rect;
	$HideTriggerBottom/CollisionTrigger.shape = rect;

func setShowTrigger():
	if has_node("ShowTrigger"):
		showTrigger = $ShowTrigger;
	if has_node("HideTriggerBottom"):
		hideTriggerB = $HideTriggerBottom
	if has_node("HideTriggerTop"):
		hideTriggerT = $HideTriggerTop

func setTriggerPos(value: float):
	if showTrigger == null:
		setShowTrigger();
	if showTrigger != null:
		hideTriggerB.position.x = value;
		hideTriggerT.position.x = value;
		showTrigger.position.x = value;

func getTriggerPos():
	if showTrigger == null:
		setShowTrigger();
	if (showTrigger != null):
		return showTrigger.position.x;
	return 0;

func setTriggerWidth(value:float):
	rect.extents.x = value
	show_rect.extents.x = value;

func getTriggerWidth():
	return rect.extents.x

func _on_ShowTrigger_body_entered(body):
	if (body.name == "Player"):
		var player:PlayerPhysics = body;
		if $AnimationPlayer.current_animation == "" ||\
			$AnimationPlayer.current_animation != "Stand":
			$AnimationPlayer.playback_speed = 2;
			$AnimationPlayer.play("Show", -1, 2)


func _on_HideTrigger_body_entered(body):
	if (body.name == "Player"):
		var player:PlayerPhysics = body;
		if ($AnimationPlayer.current_animation == "Stand"):
			$AnimationPlayer.playback_speed = 2;
			$AnimationPlayer.play("Hide", -1, 2)


func _on_AnimationPlayer_animation_finished(anim_name):
	$AnimationPlayer.playback_speed = 0;
	if(anim_name == "Show"):
		anim_name = "Stand"
	elif anim_name == "Hide":
		anim_name = "Normal"
	elif anim_name == "":
		anim_name = "Normal";
	$AnimationPlayer.play(anim_name, -1, 0)


func _on_RedSpringFromSolid_script_changed():
	_prepare();
