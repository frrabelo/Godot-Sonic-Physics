extends Node

signal state_changed(prev_state, current_state, player)

onready var states:Dictionary

onready var host = get_parent();

var current_state = 'OnGround'
var previous_state = null

func _ready() -> void:
	for i in get_children():
		if i.is_class("State"):
			states[i.name] = i

func get_available_state() -> Node:
	var to_return
	if states.has(current_state):
		to_return = states[current_state]
	elif host.selected_character.states.has(current_state):
		to_return = host.selected_character.states[current_state]
	return to_return

func _physics_process(delta):
	host.physics_step()
	var cur_state = get_available_state()
	var state_name
	if cur_state is State: state_name = cur_state.step(host, delta)
	elif cur_state is StateChar: state_name = cur_state.step(host, delta, null)
	if state_name:
		change_state(state_name)
	cur_state = null
	cur_state = get_available_state()
	
	var top_collide:Vector2 = Vector2(\
		sin(host.rotation) * 1,\
		-cos(host.rotation) * 1\
	);
	
	var bottom_snap:Vector2 = -top_collide * host.snap_margin
#	print(bottom_snap)
	#print_debug(bottom_snap)
	host.prev_position = host.position
	#var kinematic_coll:KinematicCollision2D = host.move_and_collide(host.speed * delta, true)
	#if kinematic_coll:
	#	host.speed = host.speed.slide(kinematic_coll.normal)
	host.speed = host.move_and_slide(\
		host.speed,
		top_collide,
		true,
		4,
		deg2rad(75),
		true
	)
	if cur_state is State:
		cur_state.animation_step(host, host.animation, delta)
	elif cur_state is StateChar:
		cur_state.animation_step(host, host.animation, delta, null)
	
	if host.player_camera != null:
		host.player_camera.camera_step(host, delta)

func change_state(state_name):
	if state_name == current_state:
		return
	#print(state_name)
	var cur_state = get_available_state()
	previous_state = current_state
	if cur_state is State:
		cur_state.exit(host, state_name)
	elif cur_state is StateChar:
		cur_state.exit(host, state_name, null)
	current_state = state_name
	cur_state = null
	cur_state = get_available_state()
	if cur_state is State:
		cur_state.enter(host, state_name)
	elif cur_state is StateChar:
		cur_state.enter(host, state_name, null)
	emit_signal('state_changed', previous_state, current_state, host)
