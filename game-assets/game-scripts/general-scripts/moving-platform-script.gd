tool

extends Node2D

var at_runtime:bool = false
export var init:Vector2 setget set_init_pos, get_init_pos;
export var final:Vector2 setget set_final_pos, get_final_pos;
export var time:float setget set_time, get_time;
var anim_path:NodePath = "AnimationPlayer" setget set_anim_path, get_anim_path
export(float) var delay_timer = 0.5 setget set_delay_timer, get_delay_timer
var anim_player:AnimationPlayer
var back:bool = false
onready var anim_rt = get_node(anim_path)

func _ready():
	anim_rt.get_animation("Moving").track_set_key_value(0, 0, init)
	anim_rt.get_animation("Moving").track_set_key_value(0, 1, final)
	at_runtime = true

func draw_line_point(from:Vector2, to:Vector2, color:Color, width:float,antialiasing:bool):
	draw_circle(from, 4, color)
	draw_circle(to, 4, color)
	var size = Vector2(80, 32)
	draw_rect(Rect2(from - size / 2, size), color, false)
	draw_rect(Rect2(to - size / 2, size), color, false)
	draw_line(from, to, color, width, antialiasing)

func _draw():
	draw_line_point(get_init_pos(), get_final_pos(), Color.green, 1.5, true)

func set_anim_path(value:NodePath):
	anim_path = value
	anim_player = get_node(anim_path)

func get_anim_path():
	return anim_path

func set_init_pos(value:Vector2):
	init = value
	update()
	if anim_player:
		anim_player.get_animation("Moving").track_set_key_value(0, 0, value)

func get_init_pos():
	update()
	return init

func set_final_pos(value:Vector2):
	final = value
	update()
	if anim_player:
		anim_player.get_animation("Moving").track_set_key_value(0, 1, value)

func get_final_pos():
	update()
	return final

func set_time(value:float):
	if value > 0.1:
		if anim_player:
			var anim = anim_player.get_animation("Moving")
			anim.length = value + delay_timer * 2
			anim.track_set_key_time(0, 1, value + delay_timer)
			anim.track_set_key_time(0, 0, delay_timer)

func get_time():
	if anim_player:
		return anim_player.get_animation("Moving").track_get_key_time(0, 1) - anim_player.get_animation("Moving").track_get_key_time(0, 0)

func set_delay_timer(value:float):
	delay_timer = value
	if anim_player:
		var anim = anim_player.get_animation("Moving")
		anim.track_set_key_time(0, 0, value)
		anim.track_set_key_time(0, 1, time + value + value)
		anim.length = anim.track_get_key_time(0, 1) + value

func get_delay_timer():
	return delay_timer

func _on_AnimationPlayer_animation_finished(anim_name):
	back = !back
	if back:
		anim_rt.play_backwards("Moving", -1)
	else:
		anim_rt.play("Moving", -1, 1)

func _prepare():
	at_runtime = false
	anim_player = $AnimationPlayer
