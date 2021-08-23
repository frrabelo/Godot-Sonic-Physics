extends Node2D


export(Vector2) var speed;
export(bool) var active;
onready var sprite = get_child(0);
var canFall:bool = true;
var timer:Timer;

var spawnpoint:Vector2;
# Called when the node enters the scene tree for the first time.
func _ready():
	if active:
		set_physics_process(true);
	else:
		queue_free()

func delay(sec:float):
	canFall = false;
	timer = Timer.new();
	add_child(timer);
	timer.connect("timeout", self, "canFall");
	timer.start(sec);

func canFall():
	timer.stop();
	remove_child(timer);
	canFall = true;

func _physics_process(delta):
	var distance_max = 2000
	if position.x - distance_max >= spawnpoint.x || position.y - distance_max >= spawnpoint.y ||\
		position.x + distance_max <= spawnpoint.x || position.y + distance_max <= spawnpoint.y:
		queue_free()
	if (canFall):
		sprite.rotation += (0 - sprite.rotation) / 10
		if (abs(speed.x) > 50):
			speed.x += -sign(speed.x) * 250 * delta;
		if (speed.y < 5000):
			speed.y += 1000 * delta;
		move_local_x(speed.x * delta);
		move_local_y(speed.y * delta);
	pass
