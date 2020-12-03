extends Node

export onready var states = {
	'OnGround' : $OnGround,
	'OnAir' : $OnAir,
	'SpinDash' : $SpinDash,
	'SuperPeelOut' : $SuperPeelOut,
}

onready var host = get_parent();

var current_state = 'OnGround'
var previous_state = null

func _physics_process(delta):
	host.physics_step()
	
	var state_name = states[current_state].step(host, delta)
	
	if state_name:
		change_state(state_name)
	var top_collide:Vector2 = Vector2(sin(host.rotation) * 1, -cos(host.rotation)*1);
	host.velocity = host.move_and_slide(\
		host.velocity,\
		top_collide,\
		false,\
		deg2rad(75),\
		true
	)
	states[current_state].animation_step(host, host.animation)
	host.player_camera.camera_step(host, delta)

func change_state(state_name):
	if state_name == current_state:
		return
	
	states[current_state].exit(host, state_name)
	previous_state = current_state
	current_state = state_name
	states[current_state].enter(host)

func _on_CharAnimation_animation_finished(anim_name):
	states[current_state]._on_animation_finished(anim_name)
