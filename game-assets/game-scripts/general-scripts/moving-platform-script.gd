tool

extends Node2D

var just_clicked = false
var click_inside = false
var size
onready var at_runtime:bool = false
export var init:Vector2 setget set_init_pos, get_init_pos;
export var final:Vector2 setget set_final_pos, get_final_pos;
export var time:float setget set_time, get_time;
var anim_path:NodePath = "AnimationPlayer" setget set_anim_path, get_anim_path
export(float) var delay_timer = 0.5 setget set_delay_timer, get_delay_timer
var anim_player:AnimationPlayer
var back:bool = false
onready var anim_rt = get_node(anim_path)
var collision_shape: RectangleShape2D = RectangleShape2D.new();
var click_pos
var editor_script = EditorScript.new()
var drag: Area2D = preload("res://general-objects/moving-platform-final.tscn").instance(PackedScene.GEN_EDIT_STATE_MAIN)

func _ready():
	anim_rt.get_animation("Moving").track_set_key_value(0, 0, init)
	anim_rt.get_animation("Moving").track_set_key_value(0, 1, final)
	set_time(time)
	set_delay_timer(delay_timer)
	
	at_runtime = !Engine.editor_hint
	set_process(Engine.editor_hint)

func draw_line_point(from:Vector2, to:Vector2, color:Color, width:float,antialiasing:bool):
	if collision_shape:
		size = collision_shape.extents * 2
	
	# draw 2 rectangles one on $from; and other on $to; variable
	draw_rect(Rect2(from - size / 2, size), color, false, width, true)
	draw_rect(Rect2(to - size / 2, size), color, false, width, true)
	
	# draw a line between $from; and $to; variable
	draw_line(from, to, color, width * 0.65, antialiasing)
	
	# draw lines between selected rectangle corners
	var x_side = final.x < init.x
	var y_side = final.y > init.y
	var size_arr = {false: size, true: -size}
	for i in [1, -1]:
		draw_line(\
			Vector2(\
				from.x + (size_arr[x_side].x * i) / 2,\
				from.y + (size_arr[y_side].y * i) / 2
			),\
			Vector2(\
				to.x + (size_arr[x_side].x * i) / 2,\
				to.y + (size_arr[y_side].y * i) / 2
			),\
			color,\
			width,\
			antialiasing
		)
	
	# Draw two circles on $from; and $to; variables
	for i in [from, to]:
		draw_circle(i, 2, color)

func _draw():
	if !at_runtime:
		draw_line_point(get_init_pos(), get_final_pos(), Color(0.5, 1, 0.9), 1.1, true)

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
	if drag:
		drag.position = final
	update()
	if anim_player:
		anim_player.get_animation("Moving").track_set_key_value(0, 1, value)

func get_final_pos():
	if drag:
		drag.position = final
	update()
	return final

func set_time(value:float):
	if value > 0.1:
		time = value
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
	set_process(true)
	collision_shape = $MovingPlatform/Coll.shape
	size = collision_shape.extents
	anim_player = $AnimationPlayer
	

func _process(delta):
	var mouse_pos = get_local_mouse_position()
	if Input.is_mouse_button_pressed(BUTTON_LEFT) && Input.is_key_pressed(KEY_M):
		if collision_shape && size:
			if !(mouse_pos.x < final.x - size.x / 2 ||\
				mouse_pos.x > final.x + size.x / 2) &&\
				!(mouse_pos.y < final.y - size.y / 2 ||\
				mouse_pos.y > final.y + size.y / 2) :
				if !just_clicked:
					click_inside = true
					click_pos = mouse_pos - final
		just_clicked = true
	else:
		click_inside = false
		just_clicked = false
	
	if click_inside:
		final = (((mouse_pos - click_pos) / 16).round()) * 16
		update()
 


func _on_Clickable_mouse_entered():
	set_process(true)


func _on_Clickable_mouse_exited():
	set_process(false)
