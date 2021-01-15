extends '../state.gd'

var was_damaged : bool
var has_jumped : bool
var has_rolled : bool
var has_pushed : bool
var roll_jump : bool
var can_attack : bool
var dropTimer : Timer;
var dropPress : bool;
var dropCharging : bool
var dropDust : PackedScene = preload("res://general_objects/players_objects/drop_dash_dust.tscn");
var is_floating
var override_anim : String

func enter(host):
	host.character.rotation = 0;
	dropPress = true;
	was_damaged = host.was_damaged;
	if was_damaged:
		host.invulnerable = true;
		host.control_locked = true;
	is_floating = host.is_floating;
	if !is_floating:
		has_pushed = host.has_pushed
		if !has_pushed:
			has_jumped = host.has_jumped
			has_rolled = host.is_rolling
		else:
			has_jumped = false
			has_rolled = false
	else:
		has_pushed = false;
		
	host.sprite.offset = Vector2(0, 6) if (has_rolled || has_jumped) else host.sprite.offset
	can_attack = has_jumped
	host.has_jumped = false
	host.is_rolling = false
	host.has_pushed = false;
	host.is_floating = false;
	roll_jump = has_jumped && has_rolled

func step(host, delta):
	
	if host.is_on_ceiling():
		host.velocity.y = 0;
	
	if host.is_floating:
		is_floating = true
		has_pushed = false;
		has_jumped = false;
		roll_jump = false;
		dropCharging = false;
	
	if host.has_pushed:
		has_pushed = true;
		has_jumped = false;
		has_rolled = false;
		roll_jump = false;
		dropCharging = false;
	
	if host.is_grounded:
		host.ground_reacquisition()
		was_damaged = false;
		return 'OnGround'
	
	host.velocity.x = 0 if host.is_wall_left && host.velocity.x < 0 else host.velocity.x
	host.velocity.x = 0 if host.is_wall_right && host.velocity.x > 0 else host.velocity.x

	var can_move = true if !host.control_locked && !roll_jump else false
	var no_rotation = has_jumped or has_rolled
	host.rotation_degrees = int(lerp(host.rotation_degrees, 0, .2)) if !no_rotation else 0
	
	if host.direction.x < 0 && can_move:
		if host.velocity.x > -host.TOP:
			host.velocity.x -= host.AIR
	elif host.direction.x > 0 && can_move:
		if host.velocity.x < host.TOP:
			host.velocity.x += host.AIR;
	if !has_pushed:
		if host.instaShield:
			if Input.is_action_just_pressed("ui_jump") and\
			can_attack:
				host.player_vfx.play('InstaShield', true)
				host.audio_player.play('insta_shield')
				can_attack = false
				roll_jump = false
		if has_jumped:
			if host.dropDash:
				if Input.is_action_pressed("ui_jump") && !dropPress:
					dropPress = true;
					dropTimer = Timer.new();
					self.add_child(dropTimer);
					dropTimer.start(0.325);
					dropTimer.connect("timeout", self, "_dropTimeOut", [host, delta]);
				if Input.is_action_just_released("ui_jump"):
					dropPress = false;
					if (dropTimer != null):
						dropTimer.stop();
						if has_node(dropTimer.name):
							self.remove_child(dropTimer);
						dropTimer = null;
					dropCharging = false;
				if Input.is_action_just_released("ui_jump"): # has jumped
					if host.velocity.y < -240.0: # set min jump height
						host.velocity.y = -240.0
	if host.velocity.y < 0 and host.velocity.y > -240:
		host.velocity.x -= int(host.velocity.x / 7.5) /15360
	host.velocity.y += host.GRV

func _dropTimeOut(host, delta):
	dropCharging = true;
	host.audio_player.play('drop_dash_charge');
	dropTimer.stop();
	pass

func exit(host, next_state):
	is_floating = false;
	host.is_floating = false;
	if next_state == 'OnGround' || host.is_grounded:
		if host.was_damaged:
			host.control_locked = false
			host.velocity.x = 0;
			host.gsp = 0;
		host.was_damaged = false;
		if (dropCharging):
			var dust:Node2D = dropDust.instance();
			add_child(dust);
			dust.position = host.position;
			dust.get_child(0).scale.x = host.character.scale.x
			if abs(host.gsp) < 480:
				host.player_camera.delay(0.25);
			if abs(host.gsp) < 560:
				host.gsp = \
					560 * host.character.scale.x;
			dropCharging = false;
			host.is_rolling = true;
			host.audio_player.play("spin_dash_release")
		if dropTimer != null:
			dropTimer.queue_free();
			dropPress = false;
			dropTimer.stop();
			dropTimer = null;

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
			if has_pushed:
				anim_name = "SpringJump"
				anim_speed = 3;
			else:
				if has_jumped or has_rolled:
					if !dropCharging:
						anim_name = 'Rolling';
						anim_speed = max(-((5.0 / 60.0) - (abs(host.gsp) / 120.0)), 1.0);
					else:
						anim_name = 'DropCharge';
						anim_speed = 4.5;
	
	host.character.scale.x = host.direction.x if host.direction.x != 0 else host.character.scale.x
	animator.animate(anim_name, anim_speed, true)

func when_pushed_by_spring():
	has_pushed = true;
