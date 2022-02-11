extends Node
class_name FSM

signal state_changed(prev_state, current_state, player)

onready var states:Dictionary
onready var host = get_parent();

var current_state = 'OnGround' setget change_state
var previous_state = null

func _enter_tree() -> void:
	set_physics_process(false)
	set_process_input(false)

func _ready() -> void:
	set_physics_process(false)
	set_process_input(false)
	yield(get_parent(), 'loaded')
	for i in get_children():
		if i.is_class("State"):
			states[i.name] = i
	set_physics_process(true)
	set_process_input(true)

func get_available_state() -> Node:
	var to_return
	if states.has(current_state):
		to_return = states[current_state]
	elif host.selected_character.states.has(current_state):
		to_return = host.selected_character.states[current_state]
	return to_return

func is_current_state(name:String) -> bool:
	return current_state == name

func _physics_process(delta):
	#if !host.char_default_collision_air:
	if !is_physics_processing():
		return
	host.physics_step(delta)
	var cur_state = get_available_state()
	var state_name
	$Global.step(host, delta)
	state_name = cur_state.step(host, delta)
	if state_name:
		change_state(state_name)
	if host.selected_character.states.has(current_state) && !cur_state is StateChar:
		state_name = host.selected_character.states[current_state].step(host, delta, cur_state)
		if state_name:
			change_state(state_name)
	
	cur_state = get_available_state()
	host.prev_position = host.position
	host.speed = host.move_and_slide_preset()
	if !host.specific_animation_temp:
		cur_state.animation_step(host, host.animation, delta)
	
	if host.player_camera:
		if host.im_main_player:
			host.fsm.set_process_input(true)
		host.player_camera.camera_step(host, delta)
	
	

func change_state(state_name):
	if state_name == current_state:
		return
	if host.specific_animation_temp:
		(host.animation as CharacterAnimator).playback_speed = 1.0
	host.specific_animation_temp = false
	
	#Exit
	var cur_state = get_available_state()
	cur_state.exit(host, state_name)
	if host.selected_character.states.has(current_state) && !cur_state is StateChar:
		host.selected_character.states[current_state].exit(host, state_name, cur_state)
	previous_state = current_state
	current_state = state_name
	
	#Enter
	cur_state = get_available_state()
	cur_state.enter(host, previous_state)
	if host.selected_character.states.has(current_state) && !cur_state is StateChar:
		host.selected_character.states[current_state].enter(host, previous_state, cur_state)
	emit_signal('state_changed', previous_state, current_state, host)

func _input(event: InputEvent) -> void:
	var kevt = event
	var action_chk = funcref(Utils, "is_action")
	var ui_up = 'ui_up_i%d' % host.player_index
	var ui_left = 'ui_left_i%d' % host.player_index
	var ui_right = 'ui_right_i%d' % host.player_index
	var ui_down = 'ui_down_i%d' % host.player_index
	if action_chk.call_func(ui_right) || action_chk.call_func(ui_left):
		host.direction.x = Input.get_axis(ui_left, ui_right)
	if action_chk.call_func(ui_up) || action_chk.call_func(ui_down):
		host.direction.y = Input.get_axis(ui_up, ui_down)
	
	var state = get_available_state()
	var state_name = state.state_input(host, event)
	if state_name:
		change_state(state_name)
		state = get_available_state()
	if host.selected_character.states.has(current_state) && !state is StateChar:
		state_name = host.selected_character.states[current_state].state_input(host, event, state)
		if state_name:
			change_state(state_name)

func _on_CharAnimation_animation_finished(anim_name: String) -> void:
	get_available_state()._on_animation_finished(host, anim_name)
