extends State

var slope : float

func enter(host : PlayerPhysics, prev_state):
	host.speed = Vector2.ZERO
	host.direction = Vector2.ZERO
	host.gsp = 0
	host.characters.rotation = 0

func step(host : PlayerPhysics, delta):
	var ground_angle = host.ground_angle()
	slope = host.get_slope_ratio()
	host.gsp += slope * sin(ground_angle)
	host.gsp -= min(abs(host.gsp), host.FRC) * sign(host.gsp)
	if host.gsp != 0:
		return 'OnGround'
	if host.direction != Vector2.ZERO:
		if host.direction.x != 0:
			return 'OnGround'
		if host.direction.y != 0:
			if host.direction.y > 0:
				return 'Crouch'
			else:
				return 'LookUp'
	
	if !host.is_grounded:
		return 'OnAir'
	
	if Input.is_action_just_pressed('ui_jump'):
		return host.jump()
	
	#host.speed.x = host.gsp * cos(ground_angle)
	#host.speed.y = host.gsp * -sin(ground_angle);

func animation_step(host: PlayerPhysics, animator: CharacterAnimator, delta:float):
	animator.animate('Idle', 1.0, true)


