tool
extends Node2D

onready var fan:Node2D = get_node("FanContainer");
var side:int
export(Vector2) var triggers_pos=Vector2(0, 0) setget setTriggerPos, get_trigger_pos
export(Vector2) var triggers_size=Vector2(100, 100) setget set_trigger_size, get_trigger_size;
export(Vector2) var final_pos setget set_final, get_final
var rect:RectangleShape2D = RectangleShape2D.new();
var show_trigger:Area2D;
export(Vector2) var init_pos setget set_init_pos, get_init_pos
onready var anim = $Anim
var editor_anim
var animation = Animation.new()

func _enter_tree():
	_prepare()

func _on_FromWall_script_changed():
	_prepare()



func setTriggers():
	if has_node("ShowTrigger"):
		show_trigger = $ShowTrigger;
	

func _prepare():
	setTriggers()
	editor_anim = $Anim
	show_trigger.get_node("CollisionTrigger").shape = rect;

func setTriggerPos(pos:Vector2):
	if show_trigger == null:
		setTriggers()
	if show_trigger != null:
		show_trigger.position = pos;

func get_trigger_pos():
	if show_trigger == null:
		setTriggers()
	if show_trigger != null:
		return show_trigger.position
	return 0

func set_trigger_size(size):
	if show_trigger:
		show_trigger.get_child(0).shape = rect
	rect.extents = size

func get_trigger_size():
	return rect.extents

func set_final(pos:Vector2 = Vector2.ZERO):
	if editor_anim:
		editor_anim.get_animation("FromAtoB").track_set_key_value(0, 1, pos)

func set_init_pos(pos:Vector2 = Vector2.ZERO):
	if editor_anim:
		editor_anim.get_animation("FromAtoB").track_set_key_value(0, 0, pos)

func get_final():
	if editor_anim:
		return editor_anim.get_animation("FromAtoB").track_get_key_value(0, 1)

func get_init_pos():
	if editor_anim:
		return editor_anim.get_animation("FromAtoB").track_get_key_value(0, 0)

func _on_FromWall_tree_entered():
	_prepare();


func _on_ShowTrigger_body_entered(body):
	if body.is_class("PlayerPhysics"):
		print("player_enter")
		if anim:
			anim.play("FromAtoB", -1, 1)


func _on_ShowTrigger_body_exited(body):
	if body.is_class("PlayerPhysics"):
		print("player_exit")
		if anim:
			anim.play_backwards("FromAtoB", -1)
