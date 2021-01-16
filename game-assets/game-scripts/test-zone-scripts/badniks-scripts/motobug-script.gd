extends Badnik

export var acc:float=5;
var grav:float=0;
export var grav_pattern = 1;
onready var sprite = $Motobug;
onready var anim = sprite.get_node("MotobugAnim");
var explode = preload("res://general-objects/little-explosion.tscn");
const id_badnik = "motobug";

var change = false

func uselessSetter(useless_value):
	pass

func direction():
	return (-int(!to_right) + int(to_right));

func _ready():
	speed.x = max_speed.x * direction()
	main_anim_name = "Moving"
	set_physics_process(true)

func _physics_process(delta):
	if main_anim_name != "Flipping":
		sprite.scale.x = -direction();
	if !is_on_floor():
		if grav < 128:
			grav += grav_pattern;
	else:
		grav = 0;
	
	speed.y += grav;
	var collided = move_and_collide(speed * delta, true, false, false)
	if collided:
		speed.slide(collided.normal) 
	speed = move_and_slide_with_snap(\
		speed,\
		Vector2(0, 30 * int(is_on_floor())),\
		Vector2.UP,\
		true,\
		4,\
		deg2rad(46)\
	);
	
	
	_animation_step(delta);

func _animation_step(delta):
	if change:
		if main_anim_name != "Flipping":
			main_anim_name = "Flipping"
		if (to_right && speed.x < max_speed.x) || (!to_right && speed.x > -max_speed.x):
			speed.x += acc * direction();
	
	if main_anim_name == "Moving":
		if time > 0:
			time -= delta
		else:
			if main_anim_name != "Impulsing":
				main_anim_name = "Impulsing";
	if anim.current_animation != main_anim_name:
		anim.play(main_anim_name, -1, 1, false)

func to_right_change(value:bool):
	change = true
	if to_right == value:
		return;
	else:
		if to_right != value:
			to_right = value;
			main_anim_name = "Flipping";

func _on_MotobugAnim_animation_finished(anim_name):
	match anim_name:
		"Impulsing":
			time = init_timer;
			main_anim_name = "Moving"
		"Flipping":
			change = false;
			main_anim_name = "Moving"


func _on_HitArea_body_entered(body):
	if body is PlayerPhysics:
		var player:PlayerPhysics = body;
		var ground_angle = player.ground_angle()
		var player_is_rolling =\
		player.animation.current_animation == "Rolling" ||\
		player.animation.current_animation == "DropCharge" ||\
		player.animation.current_animation == "SpinDashCharge"
		
		if !player.invulnerable && !player_is_rolling:
			player.velocity.x = 150 * (int(global_position.x < player.position.x) - int(global_position.x >= player.position.x));
			player.velocity.y = -250 * cos(rotation_degrees)
			player.is_grounded = false;
			player.damage();
			player.fsm.change_state("OnAir")
		elif player_is_rolling:
			explode_audio_player.play(0);
			if player.fsm.current_state == "OnAir":
				player.velocity.y = -(player.velocity.y * 0.85) * cos(ground_angle)
			var explode_instance = explode.instance();
			explode_instance.position = global_position;
			$"/root/main/Level".add_child(explode_instance);
			get_parent().queue_free()
