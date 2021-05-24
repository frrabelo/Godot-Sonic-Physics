extends Node

onready var states:Dictionary

onready var host = get_parent();

var current_state = 'OnGround'
var previous_state = null

func _ready() -> void:
	for i in get_children():
		if i.is_class("State"):
			states[i.name] = i
	print(states)

func _physics_process(delta):
	host.physics_step()
	
	var state_name = states[current_state].step(host, delta)
	
	if state_name:
		change_state(state_name)
	
	var top_collide:Vector2 = Vector2(\
		sin(host.rotation) * 1,\
		-cos(host.rotation) * 1\
	);
	
	var bottom_snap:Vector2 = -top_collide * host.snap_margin
#	print(bottom_snap)
	#print_debug(bottom_snap)
	host.velocity = host.move_and_slide_with_snap(\
		host.velocity,\
		bottom_snap,
		host.up_direction,\
		true,\
		4,
		deg2rad(75),\
		true
	)
	
	states[current_state].animation_step(host, host.animation)
	if host.player_camera != null:
		host.player_camera.camera_step(host, delta)

func change_state(state_name):
	if state_name == current_state:
		return
	
	states[current_state].exit(host, state_name)
	previous_state = current_state
	current_state = state_name
	states[current_state].enter(host)
