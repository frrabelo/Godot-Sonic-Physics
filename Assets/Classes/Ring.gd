extends KinematicBody2D
class_name Ring

export(float) var grav = 1.0;
export var max_speed_y:float = 300.0
export(Vector2) var speed = Vector2(0, 0);
var blink = preload("res://Assets/General Objects/RingBlink.tscn");
var instBlink:Node2D = blink.instance();
export(int) var points = 1;
export(bool) var physical = false setget set_physical, get_physical;
onready var hitBox = $Collision
onready var pick_box = $Area/Collide
var counter:float=1;
var grounded: bool = false;

func _ready():
	set_physics_process(physical)
	hitBox.set_deferred("disabled", !physical)
	#$CollisionFloor.set_deferred("disabled", !physical)
	#$Left.set_deferred("enabled", physical);
	#$Right.set_deferred("enabled", physical);

func get_physical():
	return physical;

func set_physical(value:bool):
	physical = value
	_ready();

func _physics_process(delta):
	var grounded = is_on_floor()
	
	if is_on_wall():
		speed.x *= -0.75
	
	if !grounded:
		if speed.y < max_speed_y:
			speed.y += grav;
	
	if pick_box.get("disabled"):
		if counter > 0:
			counter -= delta;
		else:
			pick_box.set_deferred("disabled", false)
	
	var collided = move_and_collide(speed * delta, false, true);
	
	if collided:
		if collided.collider.is_class(get_class()):
			add_collision_exception_with(collided.collider)
		else:
			if abs(speed.y) > 50:
				speed = speed.bounce(collided.normal) * 0.75
			else:
				speed = speed.slide(collided.normal)
	speed = move_and_slide(speed, Vector2.UP, false, 4, deg2rad(45), false)

func _on_Area_body_entered(body:Node):
	if body.is_class("PlayerPhysics"):
		queue_free()
		$"/root/main".ring += 1;
		var player:= body
		var sound:AudioPlayer = player.get_node("AudioPlayer");
		instBlink.position = position;
		instBlink.animation = floor(rand_range(0, 3));
		var instBlinkAnim:AnimatedSprite = instBlink.get_node("Anim")
		get_parent().add_child(instBlink);
		sound.play("ring");
		queue_free();

func get_class():
	return "Ring"

func is_class(name:String):
	return name == get_class();
