extends KinematicBody2D
class_name PlayerPhysics
signal damaged
enum Rays{
	LEFT_GROUND = 0,
	MIDDLE_GROUND = 1,
	RIGHT_GROUND = 2,
	LEFT_WALL_TOP = 3,
	LEFT_WALL_BOTTOM = 4
	RIGHT_WALL_TOP = 5,
	RIGHT_WALL_BOTTOM = 6
}
export(int) var CHARACTER_SELECTED = 0 setget _set_character_sel
var ACC
var DEC
var ROLLDEC
var FRC
var SLP
var SLPROLLUP
var SLPROLLDOWN
var TOP
var TOPROLL
var JMP
var FALL
var AIR
var GRV
export(bool) var spinDash = true;

onready var selected_character
onready var fsm = $StateMachine
onready var player_camera = $'../../PlayerCamera'
onready var player_vfx = $VFX
onready var GLOBAL = get_node("/root/Global");

onready var low_collider = $LowCollider
onready var ray_collider = $Ray

onready var left_ground:RayCast2D = $LeftGroundSensor
onready var right_ground:RayCast2D = $RightGroundSensor
onready var middle_ground:RayCast2D = $MiddleGroundSensor
onready var main_sensor:CollisionShape2D = $MainCollider
onready var left_wall:RayCast2D = $LeftWallSensor
onready var right_wall:RayCast2D = $RightWallSensor
onready var left_wall_bottom:RayCast2D = $LeftWallSensorBottom
onready var right_wall_bottom:RayCast2D = $RightWallSensorBottom

onready var characters = $Characters
onready var sprite
onready var char_stand_collision : RectManipulate2D
onready var char_low_collision : RectManipulate2D
onready var animation
onready var audio_player = $AudioPlayer
onready var main_scene = get_tree().current_scene
var snaps : float = 21
var snap_margin = snaps

var ring_scene = preload("res://general-objects/ring-object.tscn")

var direction : Vector2 = Vector2.ZERO;
var gsp : float
var speed : Vector2
var ground_mode : int
var control_locked : bool setget _set_control_locked
const control_unlock_time_normal = .5
var control_unlock_timer : float
onready var _control_unlock_timer_node : Timer = $ControlLockTimer
var can_fall : bool
var is_ray_colliding : bool
var is_grounded : bool
var ground_point : Vector2
var ground_normal : Vector2
var has_jumped : bool
var is_floating : bool
var is_rolling : bool setget set_is_rolling
var is_braking : bool
var was_damaged : bool
var is_wall_left : bool
var is_wall_right : bool
var is_pushing : bool
var is_looking_down : bool
var is_looking_up : bool
var spring_loaded : bool
var invulnerable : bool;
var constant_roll : bool
var up_direction : Vector2 = Vector2.UP
var prev_position : Vector2
var ground_ray : RayCast2D
var can_break_wall : bool = false setget _set_can_brake_wall
var suspended_jump : bool = false
var suspended_can_right : bool = true
var suspended_can_left : bool = true

func _ready():
	if player_camera:
		player_camera.camera_ready(self)
	_set_character_sel(CHARACTER_SELECTED)
	set_collision_mask(get_collision_mask())
	control_unlock_timer = control_unlock_time_normal

func is_on_floor() -> bool:
	return .is_on_floor()

func get_rays() -> Array:
	return [left_ground, middle_ground, right_ground, left_wall, left_wall_bottom, right_wall, right_wall_bottom]
	

func get_ray(val : int) -> RayCast2D:
	var rays = get_rays()
	return rays[val]

func set_ground_rays (val : bool) -> void:
	for i in [middle_ground, left_ground, right_ground]:
		(i as RayCast2D).set_deferred("enabled", val)

# override
func set_collision_mask(val : int) -> void:
	.set_collision_mask(val)
	for i in get_rays():
		i.set_collision_mask(val)

func set_collision_mask_bit(val : int, switch : bool) -> void:
	.set_collision_mask_bit(val, switch)
	for i in get_rays():
		i.set_collision_mask_bit(val, switch)

func _set_can_brake_wall( val : bool ) -> void:
	can_break_wall = val
	set_collision_mask_bit(5, can_break_wall)
	set_collision_layer_bit(5, can_break_wall)

func _process(delta):
	#print(speed)
	var roll_anim = animation.current_animation == 'Rolling'
	if "animation_roll" in selected_character:
		roll_anim = roll_anim || animation.current_animation == selected_character.animation_roll
	assert (char_stand_collision && char_low_collision, "Error: the variables not contains value")
	var shape = char_stand_collision.get_rectshape_2d() if !roll_anim else char_low_collision.get_rectshape_2d()
	main_sensor.shape.extents = shape.shape.extents
	main_sensor.position = shape.position
	left_ground.position.x = -9 if !roll_anim else -7
	right_ground.position.x = 9 if !roll_anim else 7
	#ray_collider.set_deferred("disabled", fsm.current_state == 'OnAir' && speed.y < 0)
	#print(roll_anim, " ", animation.current_animation)
	_set_can_brake_wall(!(abs(gsp) > 270 && is_rolling && is_grounded))
	set_collision_mask_bit(6, !roll_anim)
	set_collision_layer_bit(6, !roll_anim)
	
	#print(get_collision_mask_bit(5))
	direction.x = \
	-Input.get_action_strength("ui_left") +\
	Input.get_action_strength("ui_right")
	
	direction.y = \
	-Input.get_action_strength("ui_up") +\
	Input.get_action_strength("ui_down")

func physics_step():
	position.x = max(position.x, 9.0)
	ground_ray = get_ground_ray()
	is_ray_colliding = ground_ray != null
	
	if is_on_floor():
		is_grounded = true
	
	if is_grounded && ground_ray:
		ground_normal = ground_ray.get_collision_normal()
		ground_mode = int(round(rad2deg(ground_angle()) / 90.0)) % 4
		ground_mode = -ground_mode if ground_mode == -2 else ground_mode
	else:
		ground_mode = 0
		ground_normal = Vector2(0, -1)
		is_grounded = false
	
	is_wall_left = step_wall_collision([left_wall, left_wall_bottom]) || position.x - 9 <= 0
	is_wall_right = step_wall_collision([right_wall, right_wall_bottom])
	
	#print("left: ", is_wall_left, ", right:", is_wall_right)

func _set_control_locked(val : bool) -> void:
	control_locked = val
	if control_locked:
		_control_unlock_timer_node.start(control_unlock_timer)
	else:
		_control_unlock_timer_node.wait_time = control_unlock_time_normal
		_control_unlock_timer_node.stop()

func step_wall_collision(var wall_sensors : Array):
	var to_return = false
	for w in wall_sensors:
		var rs : RayCast2D = w
		var collider = rs.get_collider()
		if collider:
			var one_way = collider_is_one_way(rs, collider)
			if one_way:
				continue
			to_return = to_return || rs.is_colliding()
	return to_return

func collider_is_one_way(ray_cast : RayCast2D, collider) -> bool:
	var to_return : bool = false
	match collider.get_class():
		'TileMap':
			var tmap : TileMap = collider
			var cell = tmap.get_cellv(tmap.world_to_map(ray_cast.get_collision_point()))
			var shape = ray_cast.get_collider_shape()
			to_return = tmap.get_tileset().tile_get_shape_one_way(cell, shape)
		'StaticBody2D', 'RigidBody2D':
			var coll : CollisionObject2D = collider
			var collider_shape_id : int = ray_cast.get_collider_shape()
			var collider_shape_owner_id : int = coll.shape_find_owner(collider_shape_id)
			to_return = coll.is_shape_owner_one_way_collision_enabled(collider_shape_owner_id)
			
	return to_return

func fall_from_ground() -> bool:
	if abs(gsp) < FALL and ground_mode != 0:
		var angle = abs(rad2deg(ground_angle()))
		_set_control_locked(true)
		
		if angle >= 90 and angle <= 180:
			ground_mode = 0
			return true
		
	return false

func snap_to_ground() -> void:
	rotation_degrees = -rad2deg(ground_angle())
	speed += -ground_normal * 150

func ground_reacquisition():
	var ground_angle = ground_angle();
	var angle = abs(rad2deg(ground_angle))
	
	if angle >= 0 and angle < 22.5:
		gsp = speed.x
	elif angle >= 22.5 and angle < 45.0:
		if abs(speed.x) > speed.y:
			gsp = speed.x
		else:
			gsp = speed.y * .5 * -sign(sin(ground_angle))
	elif angle >= 45.0 and angle < 90:
		if abs(speed.x) > speed.y:
			gsp = speed.x
		else:
			gsp = speed.y * -sign(sin(ground_angle))
	
	rotation_degrees = -rad2deg(ground_angle)

func ground_angle() -> float:
	return ground_normal.angle_to(Vector2(0, -1))

func get_ground_ray() -> RayCast2D:
	can_fall = true
	
	if !left_ground.is_colliding() && !right_ground.is_colliding():
		return null
	elif !left_ground.is_colliding() && right_ground.is_colliding():
		return right_ground
	elif !right_ground.is_colliding() && left_ground.is_colliding():
		return left_ground
	
	can_fall = false
	
	var left_point : float
	var right_point : float
	
	match ground_mode:
		0:
			left_point = -left_ground.get_collision_point().y
			right_point = -right_ground.get_collision_point().y
		1:
			left_point = -left_ground.get_collision_point().x
			right_point = -right_ground.get_collision_point().x
		2:
			left_point = left_ground.get_collision_point().y
			right_point = right_ground.get_collision_point().y
		-1:
			left_point = left_ground.get_collision_point().x
			right_point = right_ground.get_collision_point().x
	
	if left_point >= right_point:
		return left_ground
	else:
		return right_ground

func damage(side:Vector2 = Vector2.ZERO, sound_to_play:String = "hurt"):
	if invulnerable:
		return
	emit_signal("damaged")
	var have_rings:bool = false;
	var timer = Timer.new();
	timer.connect("timeout", self, "vunerable_again", [timer])
	add_child(timer);
	timer.start(2)
	timer_ivun_start(.1)
	snap_margin = 0
	fsm.change_state("OnAir")
	is_grounded = false
	speed.x = side.x * 220
	speed.y = side.y * 200
	_set_control_locked(true)
	was_damaged = true;
	speed = move_and_slide(speed)
	if main_scene:
		var rings = main_scene.rings
		main_scene.rings = 0;
		if rings > 0:
			have_rings = true
			drop_rings(rings);
	if have_rings:
		audio_player.play("ring_loss")
		var ground_angle = ground_angle()
		position += speed * get_physics_process_delta_time()
	audio_player.play(sound_to_play)
	invulnerable = true;

func drop_rings(rings:int = 0):
	var n = false;
	var drop_max:int = 32;
	var drop_real:int = min(drop_max, rings); 
	var angle = 101.25
	var drop_speed = 200;
	var parent = get_node("/root/main/Level")
	var last_rings:Array = [];
		
	# Add all rings instances to last_rings
	for i in drop_real:
		var instance_ring:KinematicBody2D = ring_scene.instance();
		instance_ring.position = global_position;
		instance_ring.position.y -= 10
		instance_ring.speed.x = cos(angle) * drop_speed;
		instance_ring.speed.y = sin(angle) * drop_speed;
		if n:
			instance_ring.speed.x *= -1
			angle += 22.5;
		n = !n;
		if i == drop_real / 2:
			drop_speed /= 2
			angle = 101.25
		instance_ring.physical = true
		instance_ring.pick_box.set_deferred("disabled", was_damaged)
		last_rings.append(instance_ring);
		
	# Make all rings ignore each other collisions
	for c in last_rings:
		for e in last_rings:
			c.add_collision_exception_with(e);
		
	# Add all rings on level
	for r in last_rings:
		parent.add_child(r);

func timer_ivun_start(time:float):
	var timer_ivun = Timer.new();
	timer_ivun.connect("timeout", self, "toogle_visible", [timer_ivun])
	add_child(timer_ivun);
	timer_ivun.start(time);

func toogle_visible(timer:Timer):
	timer.queue_free();
	characters.visible = !characters.visible;
	if invulnerable:
		if characters.visible:
			timer_ivun_start(0.1);
		else:
			timer_ivun_start(0.025)
	else:
		characters.visible = true

func vunerable_again(timer:Timer):
	timer.queue_free();
	characters.visible = true
	invulnerable = false;

func get_class() -> String:
	return "PlayerPhysics"

func is_class(name:String) -> bool:
	return name == get_class() || .is_class(name);

func smooth_rotate(from:float, to:float, max_speed:float) -> float:
	if from == null || to == null || max_speed == null:
		return 0.0;
	var rot = to - from;
	rot = max(min(rot / 5, max_speed), -max_speed) + max(min(rot, 1), -1)
	return rot;

func set_is_rolling(val : bool):
	if val && !is_rolling:
		audio_player.play('spin')
	is_rolling = val

func _set_character_sel(val : int) -> void:
	var children = characters.get_children()
	if children is Array:
		val = val % children.size()
	else:
		val = 0
	CHARACTER_SELECTED = val
	if children[CHARACTER_SELECTED] is Node2D:
		var c : Node2D = children[CHARACTER_SELECTED]
		selected_character = c
		sprite = selected_character.get_node("Sprite")
		char_stand_collision = selected_character.get_node("StandBox")
		char_low_collision = selected_character.get_node("LowBox")
		animation = sprite.get_node("CharAnimation")
		var props = [
			"ACC", "DEC", "ROLLDEC", "FRC", "SLP", "SLPROLLUP",\
			"SLPROLLDOWN", "TOP", "TOPROLL", "JMP", "FALL", "AIR", "GRV"
		]
		for i in props:
			if !get(i):
				set(i, c.get(i))


func _on_ControlLockTimer_timeout() -> void:
	_set_control_locked(false)
	_control_unlock_timer_node.set_wait_time(control_unlock_time_normal)
