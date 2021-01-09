extends KinematicBody2D

export(float) var grav = 10.0;
export var max_speed_y:float = 300.0
export(Vector2) var speed = Vector2(0, 0);
var blink = preload("res://Assets/General Objects/RingBlink.tscn");
var instBlink:Node2D = blink.instance();
export(int) var points = 1;
export(bool) var physical = false setget set_physical, get_physical;
onready var hitBox = $Collision
onready var pick_box = $Area/Collide
var counter:float=1;

func _ready():
	print (is_in_group("Rings"));
	hitBox.set_deferred("disabled", !physical)
	set_physics_process(physical)

func get_physical():
	return physical;

func set_physical(value:bool):
	physical = value
	set_physics_process(physical)
	hitBox.set_deferred("disabled", !physical)

func _physics_process(delta):
	
	if speed.y < max_speed_y:
		speed.y += grav;
	
	var collided = move_and_collide(speed * delta, true, true);
	
	if collided:
		speed.slide(collided.normal);
	
	speed = move_and_slide(speed, Vector2.UP, false, 4, deg2rad(45), false)
	
	if speed.y != 0:
		if is_on_ceiling() || is_on_floor():
			speed.y *= -0.75
		if is_on_wall():
			speed.x *= -0.75
	
	if pick_box.get("disabled") == true:
		if counter > 0:
			counter -= delta;
		else:
			pick_box.set_deferred("disabled", false)

func _on_Area_body_entered(body):
	if body.name == "Player":
		queue_free()
		$"/root/main".ring += 1;
		var player:PlayerPhysics = body
		var sound:AudioPlayer = player.get_node("AudioPlayer");
		instBlink.position = position;
		instBlink.animation = floor(rand_range(0, 3));
		var instBlinkAnim:AnimatedSprite = instBlink.get_node("Anim")
		get_parent().add_child(instBlink);
		sound.play("ring");
		queue_free();

