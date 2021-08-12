extends '../state.gd'

var was_damaged : bool
var has_jumped : bool
var has_rolled : bool
var spring_loaded : bool
var roll_jump : bool
var can_attack : bool
var is_floating
var override_anim : String
var post_damage:bool
var can_snap:float
var was_throwed : bool = false

func enter(host, prev_state):
	host.snap_margin = 0
	can_snap = 0
	#print(prev_state)
	host.ground_container.rotation = 0
	if host.has_jumped || host.spring_loaded || host.is_rolling:
		host.characters.rotation = 0;
	was_damaged = host.was_damaged;
	#print(was_damaged)
	if host.throwed:
		was_throwed = true
		host.throwed = false
	if was_damaged:
		host.control_locked = true;
	#print(was_damaged)
	is_floating = host.is_floating;
	if !is_floating:
		spring_loaded = host.spring_loaded
	#	print(spring_loaded)
		if !spring_loaded:
			has_jumped = host.has_jumped
			has_rolled = host.is_rolling
		else:
			has_jumped = false
			has_rolled = false
	else:
		spring_loaded = false;
		has_jumped = false
		has_rolled = false
		
	host.sprite.offset = Vector2(0, 6) if (has_rolled || has_jumped) else host.sprite.offset
	can_attack = has_jumped
	host.has_jumped = false
	host.is_rolling = false
	host.spring_loaded = false;
	host.is_floating = false;
	roll_jump = has_jumped && has_rolled
	#print(host.has_jumped)
	if host.selected_character.states.has(name):
		var to_return = host.selected_character.states[name].exit(host, prev_state, self)
		if to_return:
			return to_return

func step(host, delta):
	if host.ground_normal:
		host.rotation = -host.ground_angle()
	else:
		host.rotation += (-0 - host.rotation) / (0.25/delta)
	#print(host.rotation, 'air')
	host.characters.rotation += (-host.rotation - host.characters.rotation) / (0.5/delta)
	if host.is_floating:
		has_jumped = false
		spring_loaded = false
		has_rolled = false
		is_floating = true
		can_attack = false
		host.control_locked = false
	
	if host.spring_loaded:
		spring_loaded = true
		has_jumped = false
		has_rolled = false
		is_floating = false
		can_attack = false
	
	if host.was_damaged:
		was_damaged = true
		has_jumped = false
		spring_loaded = false
		has_rolled = false
		is_floating = false
		can_attack = false
	
	#print(was_damaged)
	#print(spring_loaded, is_floating)
	
	if host.is_on_ceiling() && !spring_loaded:
		if host.speed.y < 0:
			host.speed.y = 0;
	#print(-Vector2(0, -1).floor())
	
	host.speed.x = 0 if host.is_wall_left && host.speed.x < 0 else host.speed.x
	host.speed.x = 0 if host.is_wall_right && host.speed.x > 0 else host.speed.x

	var can_move = true if !host.control_locked && !roll_jump else false
	var no_rotation = has_jumped or has_rolled
	host.rotation_degrees = int(lerp(host.rotation_degrees, 0, .2)) if !no_rotation else 0
	
	#print(prev_frame_state)
	if host.is_grounded:
		if can_snap >= 0.25:
	#	if host.speed.y >= -50:
			host.spring_loaded = false
			host.snap_margin = host.snaps
			return 'OnGround'
	
	can_snap += delta
	#print(can_snap)
	#print(prev_frame_state)
	
	
	if host.direction.x < 0 && can_move:
		if host.speed.x > -host.TOP:
			host.speed.x -= host.AIR
	elif host.direction.x > 0 && can_move:
		if host.speed.x < host.TOP:
			host.speed.x += host.AIR;
	if !spring_loaded:
		if host.selected_character.instaShield:
			if Input.is_action_just_pressed("ui_jump") and\
			can_attack:
				host.player_vfx.play('InstaShield', true)
				host.audio_player.play('insta_shield')
				can_attack = false
				roll_jump = false
		if has_jumped:
			if Input.is_action_just_released("ui_jump"): # has jumped
				if host.speed.y < -240.0: # set min jump height
					host.speed.y = -240.0
	if host.speed.y < 0 and host.speed.y > -240:
		host.speed.x -= int(host.speed.x / 7.5) /15360
	
	host.speed.y += host.GRV
	
	if host.selected_character.states.has(name):
		var to_return = host.selected_character.states[name].step(host, delta, self)
		if to_return:
			return to_return
	#print(host.speed)

func exit(host, next_state):
	can_snap = 0
	is_floating = false;
	host.is_floating = false;
	was_throwed = false
	if next_state == 'OnGround' || host.is_grounded:
		if host.was_damaged:
			host.control_locked = false
			host.speed.x = 0
			host.gsp = 0
			host.was_damaged = false
		else:
			host.ground_reacquisition()
	if host.selected_character.states.has(name):
		var to_return = host.selected_character.states[name].exit(host, next_state, self)
		if to_return:
			return to_return

func animation_step(host, animator, delta):
	var anim_name = animator.current_animation
	var anim_speed = animator.get_playing_speed()
	
	if anim_name == 'Walking':
		anim_speed = 3
	
	if anim_name == 'Braking':
		anim_name = 'Walking';
	if was_damaged:
		anim_name = "Hurt"
		anim_speed = 2
	else:
		if is_floating || was_throwed:
			anim_name = "Rotating"
			anim_speed = 3;
		else:
			if spring_loaded:
				anim_name = "SpringJump"
				anim_speed = 3;
			else:
				if has_jumped or has_rolled:
					anim_name = 'Rolling';
					host.characters.rotation = 0
					anim_speed = max(-((5.0 / 60.0) - (abs(host.gsp) / 120.0)), 1.0);
	
	if host.selected_character.states.has(name):
		var dic = host.selected_character.states[name].animation_step(host, animator, delta, self, [anim_name, anim_speed])
		if dic:
			anim_name = dic.anim_name
			anim_speed = dic.anim_speed
	
	host.characters.scale.x = host.direction.x if host.direction.x != 0 else host.characters.scale.x
	animator.animate(anim_name, anim_speed, true)

func _on_animation_finished(host, anim_name) -> void:
	match anim_name:
		'Rotating':
			if was_throwed && !is_floating:
				was_throwed = false
				host.animation.current_animation = 'Walking'

func when_pushed_by_spring():
	spring_loaded = true;
