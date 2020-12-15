tool
extends Node2D
var showTrigger:Area2D;
var eds = get_viewport();
export(Vector2) var trigger_position setget setTriggerPos, getTriggerPos;

func _ready():
	$AnimationPlayer.play("Normal", -1, 0);

func setShowTrigger():
	if has_node("ShowTrigger"):
		showTrigger = $ShowTrigger;
		showTrigger.set_process_input(true);

func setTriggerPos(value: Vector2):
	if showTrigger == null:
		setShowTrigger();
	if showTrigger != null:
		showTrigger.position = value;

func getTriggerPos():
	if showTrigger == null:
		setShowTrigger();
	if (showTrigger != null):
		return showTrigger.position;
	return Vector2.ZERO;


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
