extends Node
class_name FSM

signal state_changed(prev_state, current_state, player)

onready var states:Dictionary
onready var host = get_parent();

var current_state = 'OnGround' setget change_state
var previous_state = null

func _ready() -> void:
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

func _physics_process(delta):
	host.physics_step(delta)
	var cur_state = get_available_state()
	var state_name
	state_name = cur_state.step(host, delta)
	if state_name:
		change_state(state_name)
	cur_state = null
	cur_state = get_available_state()
	host.prev_position = host.position
	host.speed = host.move_and_slide_preset()
	cur_state.animation_step(host, host.animation, delta)
	
	if host.player_camera != null:
		host.player_camera.camera_step(host, delta)

func change_state(state_name):
	if state_name == current_state:
		return
	#print(state_name)
	var cur_state = get_available_state()
	previous_state = current_state
	cur_state.exit(host, state_name)
	current_state = state_name
	cur_state = null
	cur_state = get_available_state()
	cur_state.enter(host, state_name)
	emit_signal('state_changed', previous_state, current_state, host)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var kevt : InputEventKey = event
		var action_chk = funcref(kevt, "is_action")
		if action_chk.call_func('ui_right') || action_chk.call_func('ui_left'):
			host.direction.x = -Input.get_action_strength('ui_left') + Input.get_action_strength('ui_right')
		if action_chk.call_func('ui_up') || action_chk.call_func('ui_down'):
			host.direction.y = -Input.get_action_strength('ui_up') + Input.get_action_strength('ui_down')
		var state = get_available_state()
		get_available_state().state_input(host, event)


func _on_CharAnimation_animation_finished(anim_name: String) -> void:
	get_available_state()._on_animation_finished(host, anim_name)
