tool
extends Node2D

onready var fan:Node2D = get_node("FanContainer");
var side:int
export(Vector2) var triggers_pos=Vector2(0, 0) setget setTriggerPos, get_trigger_pos
export(Vector2) var triggers_size=Vector2(100, 100) setget set_trigger_size, get_trigger_size;
export(Vector2) var final_pos
export(float) var speed: float = 1.0
var rect:RectangleShape2D = RectangleShape2D.new();
var show_trigger:Area2D;
export(Vector2) var init_pos
var inside : bool = false
var players_inside : Array = []

func _enter_tree():
	_prepare()

func _on_FromWall_script_changed():
	_prepare()

func _ready() -> void:
	set_process(false)


func setTriggers():
	if has_node("ShowTrigger"):
		show_trigger = $ShowTrigger;
	

func _prepare():
	setTriggers()
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

func _on_FromWall_tree_entered():
	_prepare();


func _on_ShowTrigger_body_entered(body):
	if body.is_class("PlayerPhysics"):
		print("player_enter")
		if !players_inside.has(body):
			players_inside.append(body)
		inside = true
		if players_inside.size() > 0:
			set_process(true)


func _on_ShowTrigger_body_exited(body):
	if body.is_class("PlayerPhysics"):
		print("player_exit")
		if players_inside.has(body):
			players_inside.remove(players_inside.find(body))
		if players_inside.size() < 1:
			inside = false
			set_process(true)

func _process(delta: float) -> void:
	var target_position
	var direction
	var motion
	var distance_to_target
	
	if inside:
		target_position = final_pos
	else:
		target_position = init_pos
	
	print(target_position)
	direction = (target_position - fan.position).normalized()
	motion = direction * delta * speed*100
	distance_to_target = fan.position.distance_to(target_position)
	if motion.length() >= distance_to_target:
		fan.position = target_position
		set_process(false)
	else:
		fan.position += motion
