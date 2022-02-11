extends KinematicBody2D
class_name Ring

export(float) var grav = 7.5;
export var max_speed_y:float = 900.0
export(Vector2) var speed = Vector2(0, 0);
var blink = preload("res://general-objects/ring-sparkle-object.tscn");
var instBlink:Node2D = blink.instance();
export(int) var points = 1;
export(bool) var physical = false setget set_physical, get_physical;
onready var hitBox = $Collision
onready var pick_box = $Area/Collide
var counter:float=1;
var grounded: bool = false;
var exit_timer:float = 4

func _ready():
	set_physics_process(physical)
	hitBox.set_deferred("disabled", !physical)

func get_physical():
	return physical;

func set_physical(value:bool):
	physical = value
	set_physics_process(physical)
	hitBox.set_deferred("disabled", !physical)

func _physics_process(delta):
	var grounded = is_on_floor()
	
	if speed.y < max_speed_y:
		speed.y += grav;
	
	if grounded:
		if speed.x != 0:
			speed.x += 0.00001 * -int(speed.x > 0) + int(speed.x < 0)
		if abs(speed.x) < 0.1:
			speed.x = 0;
	if pick_box.get("disabled"):
		if counter > 0:
			counter -= delta;
		else:
			pick_box.set_deferred("disabled", false)
	
	var prev_speed = speed;
	
	speed = move_and_slide(speed, Vector2(0, -1), false, 4, deg2rad(45), false)
	
	var collided = move_and_collide(speed * delta, false, true, false);
	
	if collided:
		if collided.collider.is_class(get_class()):
			add_collision_exception_with(collided.collider)
			
		else:
			var abs_speed = Vector2(abs(speed.x), abs(speed.y))
			if abs_speed.y > 10 || abs_speed.x > 10:
				speed = prev_speed.bounce(collided.normal)  * 0.75
			else:
				speed = speed.slide(collided.normal) * 2
	
	if exit_timer < 1.5:
		visible = !visible
	
	if exit_timer > 0:
		exit_timer -= delta;
	else:
		queue_free()

func _on_Area_body_entered(body:Node):
	match body.get_class():
		"PlayerPhysics":
			_catch(body)
		"Ring":
			add_collision_exception_with(body)

func get_class():
	return "Ring"

func is_class(class_:String):
	return class_ == get_class() or class_ == .get_class();


func _on_Area_area_entered(area: Area2D) -> void:
	if area.get_owner().is_class('Rocket'):
		if area.get_owner().can_ascend == true && area.get_owner().player:
			var player = area.get_owner().player
			_catch(player)

func _catch(body: Node) -> void:
	get_tree().get_current_scene().rings += points;
	var player:= body
	var sound:AudioPlayer = player.get_node("AudioPlayer");
	instBlink.position = position;
	instBlink.animation = floor(rand_range(0, 3));
	var instBlinkAnim:AnimatedSprite = instBlink.get_node("Anim")
	get_parent().add_child(instBlink);
	sound.play("ring");
	queue_free()
