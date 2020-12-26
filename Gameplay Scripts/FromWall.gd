tool
extends Node2D

onready var fan:Node2D = get_node("FanContainer");
var side:int
export var quantity: int=1;
export var triggers_x:float=0 setget setTriggerPos, getTriggerPos
export var triggers_w:float=100 setget setTriggerW, getTriggerW;
var rect:RectangleShape2D = RectangleShape2D.new();
var appearRect:RectangleShape2D = RectangleShape2D.new()

func _enter_tree():
	prepare()

func _physics_process(delta):
	var maxMove:int = 32 * quantity
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

func _on_FromWall_script_changed():
	prepare()

func prepare():
	appearRect.extents = Vector2(triggers_w, 90)
	rect.extents = Vector2(triggers_w, 3)
	$Appear/Collide.shape = appearRect;
	$DisappearBottom/Collide.shape = rect;
	$DisappearTop/Collide.shape = rect;

func setTriggerPos(pos:float):
	$Appear.position.x = pos;
	$DisappearBottom.position.x = pos;
	$DisappearTop.position.x = pos;

func getTriggerPos():
	return $Appear.position.x

func setTriggerW(size:float):
	rect.extents.x = size
	appearRect.extents.x = size;

func getTriggerW():
	return rect.extents.x
