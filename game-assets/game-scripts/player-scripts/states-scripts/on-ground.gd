extends State

var slope : float
var is_braking : bool
var idle_anim = 'Idle'
var brake_sign : int
var spring: Node2D

func enter(host, prev_state):
	host.is_pushing = false
	#host.spring_loaded = false
	idle_anim = 'Idle'
	host.snap_margin = host.snaps
	host.suspended_jump = false
	
	if host.selected_character.states.has(name):
		var to_return = host.selected_character.states[name].enter(host, prev_state, self)
		if to_return:
			return to_return
	

func step(host, delta):
	host.is_looking_down = false
	host.is_looking_up = false
	var gsp_dir = sign(host.gsp)
	var abs_gsp = abs(host.gsp)
	if host.was_damaged:
		host.snap_margin = 0
		return 'OnAir'
	
	if !host.is_ray_colliding || host.fall_from_ground():
		host.is_grounded = false
		host.move_and_slide(host.speed)
		host.snap_margin = 0
		return 'OnAir'
	
	if host.is_floating:
		return 'OnAir'
	
	if host.constant_roll:
		host.is_rolling = true
		host.gsp += ((host.TOPROLL - host.gsp) * delta) * host.characters.scale.x * host.ACC
		host.gsp = max(-host.TOPROLL, min(host.gsp, host.TOPROLL))
	#	print(host.gsp)
		host.control_locked = true
		host.control_unlock_timer = 0.5
	else:
		if host.direction.y != 0:
			if host.direction.y > 0:
				if abs_gsp > 61.875:
					host.is_rolling = true
				elif host.ground_mode == 0:
					host.is_rolling = false
					if host.spinDash || host.selected_character.get("spin_dash_override"):
							if Input.is_action_just_pressed("ui_jump"):
								return 'SpinDash'
					host.is_looking_down = true
	
	var ground_angle = host.ground_angle();
	
	if host.is_rolling and abs_gsp < 30.0:
		host.is_rolling = false
	
	if !host.is_rolling:
		slope = -host.SLP
	else:
		if sign(host.gsp) == sign(sin(ground_angle)):
			slope = -host.SLPROLLUP
		else:
			slope = -host.SLPROLLDOWN
	
	host.gsp += slope * sin(ground_angle)
	abs_gsp = abs(host.gsp)
	if !host.control_locked:
		if host.direction.x != 0:
			if host.direction.x == -gsp_dir:
				if abs_gsp > 0 :
					var braking_dec : float = host.DEC if !host.is_rolling else host.ROLLDEC
					host.gsp += braking_dec * host.direction.x
				if abs_gsp >= 380 && !host.is_rolling:
					if !is_braking:
						brake_sign = gsp_dir
						host.audio_player.play('brake')
					is_braking = true
			
			if !is_braking && abs_gsp < host.TOP && !host.is_rolling:
					host.gsp += host.ACC * host.direction.x;
		else:
			is_braking = false
			if !host.is_rolling:
				host.gsp -= min(abs_gsp, host.FRC) * sign(host.gsp)
				abs_gsp = abs(host.gsp)
	
	if host.is_wall_right && host.gsp > 0 || host.is_wall_left && host.gsp < 0:
		host.is_pushing = true
	else:
		host.is_pushing = false
	
	if gsp_dir != brake_sign or abs_gsp <= 0.01:
		is_braking = false
	
	host.is_braking = is_braking
	
	if host.is_rolling:
		host.gsp -= min(abs_gsp, host.FRC / 2.0) * sign(host.gsp)
		host.gsp = clamp(host.gsp, -host.TOPROLL, host.TOPROLL)
	elif host.is_looking_down:
		host.gsp = .0
	
	host.gsp = .0 if host.is_wall_left and host.gsp < 0 else host.gsp
	host.gsp = .0 if host.is_wall_right and host.gsp > 0 else host.gsp
	host.speed.x = host.gsp * cos(ground_angle)
	host.speed.y = host.gsp * -sin(ground_angle);
	
	if host.selected_character.states.has(name):
		var to_return = host.selected_character.states[name].step(host, delta, self)
		if to_return:
			return to_return
	
	if Input.is_action_just_pressed("ui_jump"):
		host.speed.x += -host.JMP * sin(ground_angle)
		host.speed.y += -host.JMP * cos(ground_angle)
		host.speed = host.move_and_slide(host.speed, host.up_direction, true, 4, deg2rad(75))
		host.rotation_degrees = 0
		host.is_grounded = false
		host.spring_loaded = false
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
	
	if host.selected_character.states.has(name):
		var to_return = host.selected_character.states[name].exit(host, next_stage, self)
		if to_return:
			return to_return

func animation_step(host, animator, delta):
	var gsp_dir = sign(host.gsp)
	var anim_name = idle_anim
	var anim_speed = 1.0
	var abs_gsp = abs(host.gsp);
	var play_once = false
	host.rotation_degrees = round(host.rotation_degrees)
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
			host.characters.global_rotation = 0;
			var side = sign(host.characters.scale.x);
			if side == 0: side = 1
			host.sprite.offset.x = (-6) * (sin(host.characters.rotation) * -side);
			var up = host.sprite.offset.y < 0;
			var cdown = host.sprite.offset.y >= 0;
			var numBase = {up : 6, cdown : 6}
			host.sprite.offset.y = numBase[true] * cos(host.characters.rotation);
			anim_name = 'Rolling'
			anim_speed = -((5.0 / 60.0) - (abs(host.gsp) / 120.0))
		else:
			var host_char = host.characters
			var char_rotation = host_char.rotation_degrees;
			var host_rotation = host.rotation_degrees
			var abs_crot = abs(host_rotation)
			if abs_crot < 20:
				if abs_crot < 10:
					host_char.global_rotation = 0;
				host_char.rotation += (0 - char_rotation) * (delta)
			else:
				pass
				host_char.rotation += (0 - char_rotation) * (delta*2)
			anim_speed = max(-(8.0 / 60.0 - (abs_gsp / 120.0)), 1.6)
			if gsp_dir != 0:
				host.characters.scale.x = gsp_dir
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
	
	if host.selected_character.states.has(name):
		host.selected_character.states[name].animation_step(host, animator, self, delta)
	
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
			var gsp_dir = sign(host.gsp);
			if (host.gsp != 0 ||\
			host.direction.x == -gsp_dir) &&\
			host.direction.x != 0:
				anim_name = 'PostBrakReturn'
			elif host.direction.x == 0 ||\
			host.direction.x == gsp_dir:
				is_braking = false;
				idle_anim = 'Idle';
			
	pass # Replace with function host.
