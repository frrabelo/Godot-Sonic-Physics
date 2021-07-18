extends State

func enter(host : PlayerPhysics, prev_state : String):
	host.speed = Vector2.ZERO

func step(host : PlayerPhysics, delta: float):
	if !host.is_grounded:
		return 'OnAir'
	var sub_state = host.selected_character.states[state_machine.current_state].step(host, delta, self)

func animation_step(host: PlayerPhysics, animator: CharacterAnimator, delta:float):
	var play_speed = 1.25
	var animation = 'LookUp'
	if host.direction.y > -1:
		animation = 'UpToIdle'
	#print(animator.current_animation)
	animator.animate(animation, play_speed, true)

func _on_animation_finished(host:PlayerPhysics, anim_name: String):
	match anim_name:
		'UpToIdle':
			host.fsm.change_state('Idle')

func state_input(host, event):
	var sub_state = host.selected_character.states[state_machine.current_state].state_input(host, event, self)
