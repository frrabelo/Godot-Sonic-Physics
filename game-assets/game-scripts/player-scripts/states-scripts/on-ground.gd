extends '../state.gd'

var slope : float
var is_braking : bool
var idle_anim = 'Idle'
var brake_sign : int
var spring: Node2D

func enter(host):
	host.is_pushing = false
	host.has_pushed = false
	idle_anim = 'Idle'

func step(host:PlayerPhysics, delta):
	host.is_looking_down = false
	host.is_looking_up = false
	var gsp_dir = bool_side(host.gsp < 0, host.gsp > 0)
	
	if (!host.is_ray_colliding || host.fall_from_ground()):
		host.position.x += -sin(host.ground_angle()) * 5
		host.position.y += cos(host.ground_angle()) * 5
		host.is_grounded = false
		return 'OnAir'
	
	if host.direction.y > 0:
		if abs(host.gsp) > 61.875:
			if !host.is_rolling:
				host.audio_player.play('spin')
			host.is_rolling = true
		elif host.ground_mode == 0:
			host.is_rolling = false
			if host.spinDash:
				if Input.is_action_just_pressed("ui_jump"):
					return 'SpinDash'
			host.is_looking_down = true
	elif host.direction.y < 0:
		if abs(host.gsp) < .1 and host.ground_mode == 0:
			if Input.is_action_just_pressed("ui_jump") && host.superPeelOut:
				return 'SuperPeelOut'
			host.is_looking_up = true
	
	var ground_angle = host.ground_angle();
	
	if host.is_rolling and abs(host.gsp) < 30.0:
		host.is_rolling = false
	
	if !host.is_rolling:
		slope = -host.SLP
	else:
		if sign(host.gsp) == sign(sin(ground_angle)):
			slope = -host.SLPROLLUP
		else:
			slope = -host.SLPROLLDOWN
	host.gsp += slope * sin(ground_angle)
	var abs_gsp = abs(host.gsp)
	if !host.control_locked:
		if host.direction.x == -gsp_dir:
			if abs_gsp > 0 :
					host.gsp += (host.DEC if !host.is_rolling else host.ROLLDEC) * host.direction.x
			if abs_gsp >= 380 && !host.is_rolling:
				if !is_braking:
					brake_sign = sign(host.gsp)
					host.audio_player.play('brake')
				is_braking = true
		if host.direction.x != 0:
			if !is_braking && abs_gsp < host.TOP && !host.is_rolling:
				host.gsp += host.ACC * (host.direction.x);
		else:
			if !host.is_rolling:
				host.gsp -= min(abs_gsp, host.FRC) * sign(host.gsp)
	
	if host.is_wall_right && host.gsp > 0 || host.is_wall_left && host.gsp < 0:
		host.is_pushing = true
	else:
		host.is_pushing = false;
	
	if sign(host.gsp) != brake_sign or abs_gsp <= 0.01:
		is_braking = false
	
	host.is_braking = is_braking
	
	if host.is_rolling:
		host.gsp -= min(abs_gsp, host.FRC / 2.0) * sign(host.gsp)
		host.gsp = clamp(host.gsp, -host.TOPROLL, host.TOPROLL)
	elif host.is_looking_down:
		host.gsp = .0
	
	host.gsp = .0 if host.is_wall_left and host.gsp < 0 else host.gsp
	host.gsp = .0 if host.is_wall_right and host.gsp > 0 else host.gsp
	host.velocity.x = host.gsp * cos(ground_angle)
	host.velocity.y = host.gsp * -sin(ground_angle);
	
	if Input.is_action_just_pressed("ui_jump"):
		host.velocity.x += -host.JMP * sin(ground_angle)
		host.velocity.y += -host.JMP * cos(ground_angle)
		host.position += host.velocity * delta
		host.rotation_degrees = 0
		host.is_grounded = false
		host.has_pushed = false
		host.is_floating = false
		host.has_jumped = true
		host.snap_margin = 0
		host.audio_player.play('jump')
		return 'OnAir'
	
	if !host.can_fall:
		host.snap_to_ground()

func exit(host, next_stage):
	is_braking = false
	host.is_braking = false
	if next_stage == "OnAir":
		host.snap_margin = 0

func animation_step(host, animator):
	var gsp_dir = bool_side(host.gsp < 0, host.gsp > 0)
	var anim_name = idle_anim
	var anim_speed = 1.0
	var abs_gsp = abs(host.gsp);
	var play_once = false
	if abs_gsp > .1 and !is_braking:
		idle_anim = 'Idle'
		anim_name = 'Walking'
		if abs_gsp > 0:
			if abs_gsp >= 250:
				anim_name = 'Jogging'
			
			if abs_gsp >= 380:
				anim_name = 'Running'
			
			if abs_gsp >= 960:
				anim_name = 'SuperPeelOut'
		
		if host.is_rolling:
			host.character.global_rotation = 0;
			var side = -int(host.character.scale.x < 0) + int(host.character.scale.x >= 0);
			host.sprite.offset.x = (-8) * (sin(host.character.rotation) * -side);
			var up = host.sprite.offset.y < 0;
			var cdown = host.sprite.offset.y >= 0;
			var numBase = {up : 14, cdown : 6}
			host.sprite.offset.y = numBase[true] * cos(host.character.rotation);
			anim_name = 'Rolling'
			anim_speed = -((5.0 / 60.0) - (abs(host.gsp) / 120.0))
		else:
			var host_char = host.character
			var char_rotation = host_char.rotation_degrees;
			var host_rotation = host.rotation_degrees
			var abs_crot = abs(host_rotation)
			if abs_crot < 20:
				if abs_crot < 10:
					host_char.global_rotation = 0;
				host_char.rotation_degrees += host.smooth_rotate(char_rotation, -host_rotation, 1.0)
			else:
				host_char.rotation_degrees += host.smooth_rotate(char_rotation, 0, 360.0)
			anim_speed = max(-(8.0 / 60.0 - (abs_gsp / 120.0)), 1.6)
		
			host.character.scale.x =\
			gsp_dir\
			if (host.gsp != 0) else\
				host.character.scale.x;
	elif is_braking:
		if anim_name != 'BrakeLoop' && anim_name != 'PostBrakReturn':
			anim_name = 'Braking'
		anim_speed = 2.0
		play_once = true;
		match anim_name:
			'BrakeLoop': 
				anim_speed = -((5.0 / 60.0) - (abs(host.gsp) / 120.0));
				play_once = false;
			'PostBrakReturn':
				anim_speed = 1;
		
	else:
		if host.is_looking_down:
			idle_anim = 'Idle'
			anim_name = 'Down'
			anim_speed = 3;
			play_once = true
		elif host.is_looking_up:
			idle_anim = 'Idle'
			anim_name = 'LookUp'
			anim_speed = 2;
			play_once = true;
		elif host.is_pushing:
			idle_anim = 'Idle'
			anim_name = 'Pushing'
			anim_speed = 1.5;
	
	animator.animate(anim_name, anim_speed, play_once);

func _on_animation_finished(anim_name):
	if anim_name == 'Walking':
		is_braking = false
	elif anim_name == 'Idle':
		idle_anim = 'Idle'
	elif anim_name == 'Idle':
		idle_anim = 'Idle'


func _on_CharAnimation_animation_finished(anim_name):
	var mac = get_parent();
	var host = mac.get_parent();
	match anim_name:
		'Walking': is_braking = false;
		'Idle': idle_anim = 'Idle';
		'Braking':
			var gsp_dir = bool_side(host.gsp < 0, host.gsp > 0);
			if (host.gsp != 0 ||\
			host.direction.x == -gsp_dir) &&\
			host.direction.x != 0:
				anim_name = 'PostBrakReturn'
			elif host.direction.x == 0 ||\
			host.direction.x == gsp_dir:
				is_braking = false;
				idle_anim = 'Idle';
			
	pass # Replace with function host.

func bool_side(to_left:bool, to_right:bool):
	var left = -int(to_left)
	var right = int(to_right)
	return left + right
