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
var prev_frame_state:PoolStringArray = []

func enter(host, prev_state):
	prev_frame_state.push_back(prev_state)
	#print(prev_state)
	host.characters.rotation = 0;
	was_damaged = host.was_damaged;
	#print(was_damaged)
	if was_damaged:
		host.control_locked = true;
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
	if host.is_floating:
		has_jumped = false
		spring_loaded = false
		has_rolled = false
		is_floating = true
	
	if host.spring_loaded:
		spring_loaded = true
		has_jumped = false
		has_rolled = false
		is_floating = false
	
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
		if prev_frame_state[0] != "OnGround":
	#	if host.speed.y >= -50:
			host.spring_loaded = false
			host.ground_reacquisition()
			return 'OnGround'
	
	prev_frame_state.push_back("OnAir")
	if prev_frame_state.size() > 25:
		prev_frame_state.remove(0)
	if prev_frame_state[0] != "OnGround":
		host.set_rays(true)
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
	prev_frame_state = []
	is_floating = false;
	host.is_floating = false;
	if next_state == 'OnGround' || host.is_grounded:
		if host.was_damaged:
			host.control_locked = false
			host.speed.x = 0
			host.gsp = 0
			host.was_damaged = false
	if host.selected_character.states.has(name):
		var to_return = host.selected_character.states[name].exit(host, next_state, self)
		if to_return:
			return to_return

func animation_step(host, animator):
	var anim_name = animator.current_animation
	var anim_speed = animator.get_playing_speed()
	
	if anim_name == 'Braking':
		anim_name = 'Walking';
	
	if was_damaged:
		anim_name = "Hurt"
		anim_speed = 2
	else:
		if is_floating:
			anim_name = "Rotating"
			anim_speed = 3;
		else:
			if spring_loaded:
				anim_name = "SpringJump"
				anim_speed = 3;
			else:
				if has_jumped or has_rolled:
					anim_name = 'Rolling';
					anim_speed = max(-((5.0 / 60.0) - (abs(host.gsp) / 120.0)), 1.0);
	
	if host.selected_character.states.has(name):
		var dic = host.selected_character.states[name].animation_step(host, animator, self, [anim_name, anim_speed])
		if dic:
			anim_name = dic.anim_name
			anim_speed = dic.anim_speed
	
	host.characters.scale.x = host.direction.x if host.direction.x != 0 else host.characters.scale.x
	animator.animate(anim_name, anim_speed, true)

func when_pushed_by_spring():
	spring_loaded = true;
