extends '../state.gd'

var p : float # spin dash release power

func enter(host, prev_state):
	p = 0
	host.player_vfx.play('ChargeDust', false)
	host.audio_player.play('spin_dash_charge')

func step(host, delta):
	if Input.is_action_just_released("ui_down"):
		return 'OnGround'
	
	if Input.is_action_just_pressed("ui_jump"):
		p += 120
		host.animation.stop(true)
		host.audio_player.play('spin_dash_charge')
	
	host.rotation_degrees = 0;
	
	p = min(p, 480)
	p -= int(p / 7.5) / 15360.0

func exit(host, next_state):
	host.is_rolling = true
	host.gsp = (480 + (floor(p) / 2)) * host.characters.scale.x
	host.player_vfx.stop('ChargeDust')
	host.audio_player.stop('spin_dash_charge')
	host.audio_player.play('spin_dash_release')

func animation_step(host, animator):
	animator.animate('SpinDashCharge', 3.0, false)
	pass
