tool
extends Node2D

onready var fan:Node2D = get_node("FanContainer");
var side:int
export var quantity: int=1;
export(float) var triggers_x=0 setget setTriggerPos, getTriggerPos
export(float) var triggers_w=100 setget setTriggerW, getTriggerW;
var rect:RectangleShape2D = RectangleShape2D.new();
var appearRect:RectangleShape2D = RectangleShape2D.new()
var maxMove:int;
var show_trigger:Area2D;
var hide_bottom:Area2D
var hide_top:Area2D;

func _enter_tree():
	_prepare()

func _on_FromWall_script_changed():
	_prepare()

func _ready():
	maxMove = 32 * quantity

func _physics_process(delta):
	
	var step = maxMove / 10;
	var is_on_side = -int(fan.position.x < 0) + int (fan.position.x > 0)
	if fan != null:
		if side == 0:
			if fan.position.x != 0:
				fan.move_local_x(-is_on_side * step);
			else:
				set_physics_process(false)
		else:
			if abs(fan.position.x) < maxMove:
				fan.move_local_x(side * step);
			else:
				print("limit")
				set_physics_process(false)

func _on_Appear_body_entered(body):
	if body.name == "Player":
		var player:PlayerPhysics = body;
		if side == 0:
			side = - int(player.position.x < position.x) + int(player.position.x > position.x)
			set_physics_process(true)

func _on_Disappear_body_entered(body):
	if body.name == "Player":
		if side != 0:
			side = 0;
			set_physics_process(true)

func setTriggers():
	if has_node("Appear"):
		show_trigger = $Appear;
	if has_node("DisappearBottom"):
		hide_bottom = $DisappearBottom
	if has_node("DisappearTop"):
		hide_top = $DisappearTop

func _prepare():
	setTriggers()
	appearRect.extents.y = 90
	rect.extents.y = 3
	show_trigger.get_node("Collide").shape = appearRect;
	hide_top.get_node("Collide").shape = rect;
	hide_bottom.get_node("Collide").shape = rect;

func setTriggerPos(pos:float):
	if show_trigger == null:
		setTriggers()
	if show_trigger != null:
		show_trigger.position.x = pos;
		hide_top.position.x = pos;
		hide_bottom.position.x = pos;

func getTriggerPos():
	if show_trigger == null:
		setTriggers()
	if show_trigger != null:
		return $Appear.position.x
	return 0

func setTriggerW(size:float):
	rect.extents.x = size
	appearRect.extents.x = size;

func getTriggerW():
	return rect.extents.x


func _on_FromWall_tree_entered():
	_prepare();
