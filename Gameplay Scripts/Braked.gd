extends Node2D


export(Vector2) var speed;
export(bool) var active;


# Called when the node enters the scene tree for the first time.
func _ready():
	if active:
		set_physics_process(true);
	else:
		get_parent().remove_child(self);
	pass # Replace with function body.

func _physics_process(delta):
	if (speed.x > 50):
		speed.x -= 100 * delta;
	if (speed.y < 5000):
		speed.y += 1000 * delta;
	move_local_x(speed.x * delta);
	move_local_y(speed.y * delta);
	pass
