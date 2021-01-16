tool
extends Node2D
var showTrigger:Area2D;
export(float) var trigger_position = 80 setget setTriggerPos, getTriggerPos;
export(float) var trigger_width = 80 setget setTriggerWidth, getTriggerWidth
var show_rect:RectangleShape2D = RectangleShape2D.new();
export var initial_angle : float = 0 setget setInitAngle, getInitAngle;
export var final_angle : float = 180;
var activate:bool = false;

func _ready():
	$SpPlat.rotation_degrees = initial_angle;

func _enter_tree():
	_prepare();

func _prepare():
	setShowTrigger()
	show_rect.extents.y = 120
	set_process(false)
	$ShowTrigger/CollisionTrigger.shape = show_rect;

func setInitAngle(value:float):
	set_process(false);
	initial_angle = fmod(value, 360);
	$SpPlat.rotation_degrees = initial_angle;

func getInitAngle():
	return initial_angle;

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
	if body is PlayerPhysics:
		activate = true;
		set_process(true);

func _on_ShowTrigger_body_exited(body):
	if body is PlayerPhysics:
		activate = false;
		set_process(true);
	
func _process(delta):
	if initial_angle == final_angle:
		set_process(false);
		return
	var minor = min(initial_angle, final_angle);
	var major = max(initial_angle, final_angle);
	if activate:
		if $SpPlat.rotation_degrees != final_angle:
			$SpPlat.rotation_degrees +=\
				(major - minor) / 5;
		else:
			set_process(false);
	else:
		if $SpPlat.rotation_degrees != initial_angle:
			$SpPlat.rotation_degrees +=\
				(major - minor) / 5;
		else:
			set_process(false);
	$SpPlat.rotation_degrees = fmod($SpPlat.rotation_degrees, 360);
func _on_RedSpringFromSolid_script_changed():
	_prepare();
