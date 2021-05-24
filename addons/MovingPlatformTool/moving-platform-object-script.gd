tool
extends Node2D
class_name MovingPlatformObject

export(PoolVector2Array) var positions = [Vector2.ZERO] setget set_positions
export var loop : bool = false setget set_loop
export var speed : float = 1.0
export var pause_timer : float = 1.0
export(bool) var editor_processing = false setget set_editor_process
export(Color) var preview_color = Color.azure setget set_preview_color
var current_target : int = 0
var platform : KinematicBody2D
var dir : int = 1

func set_all () -> void:
	for i in get_children():
		if i is KinematicBody2D:
			platform = i

func _enter_tree() -> void:
	set_all()
	if Engine.editor_hint:
		update_configuration_warning()

func _ready() -> void:
	set_all()
	if Engine.editor_hint:
		set_physics_process(editor_processing)
	else:
		set_physics_process(true)
	#print(is_physics_processing())

func set_positions(val:PoolVector2Array) -> void:
	positions = val
	update()

func set_preview_color(val: Color) -> void:
	preview_color = val
	update()

func set_loop (val:bool) -> void:
	loop = val
	update()

func draw_point_to_point(a:Vector2, b:Vector2, size:Vector2, color:Color, stroke_size:float = 1.0, fill:bool = true, antialiazing:bool = false):
	draw_line(a, b, color, 2.0, antialiazing)
	if fill:
	#	draw_rect(Rect2(a - size, size * 2), color, fill)
		draw_rect(Rect2(b - size, size * 2), color, fill)
	else:
	#	draw_rect(Rect2(a - size, size * 2), color, fill, stroke_size, antialiazing)
		draw_rect(Rect2(b - size, size * 2), color, fill, stroke_size, antialiazing)

func _draw() -> void:
	if !Engine.editor_hint:
		return
	for i in get_children():
		if i is KinematicBody2D:
			platform = i
	var size = get_size()
	draw_rect(Rect2(positions[0] - size, size * 2), preview_color, true)
	draw_point_to_point(positions[0], positions[0] + positions[1], size, preview_color, 2.0, true)
	for i in range(1, positions.size() - 1):
		draw_point_to_point(positions[i], positions[i+1], size, preview_color, 2.0, true)
	
	if loop:
		var last_pos = positions[positions.size()-1] 
		draw_line(last_pos, positions[0], preview_color, 2.0, true)

func get_size() -> Vector2:
	var to_return : Vector2
	for i in get_children():
		if i is KinematicBody2D:
			for j in i.get_children():
				if j is CollisionShape2D:
					to_return = j.shape.extents
	
	return to_return

func _physics_process(delta: float) -> void:
	var target_position = positions[current_target]
	var direction:Vector2 = (target_position - platform.position).normalized()
	var motion: = direction * speed * delta
	var distance_to_target: = platform.position.distance_to(target_position)
	if motion.length() >= distance_to_target:
		platform.position = target_position
		current_target += dir
		if !loop:
			if current_target == positions.size() -1 || (current_target == 0 && dir < 0):
				dir = -dir
		else:
			current_target = current_target % positions.size()
		target_position = positions[current_target]
		set_physics_process(false)
		var timer = Timer.new()
		timer.connect('timeout', self, "_timer_timeout", [timer])
		add_child(timer)
		timer.start(pause_timer)
		#print(timer.time_left)
	else:
		platform.position += motion
		#print(distance_to_target, motion.length(), current_target)
	#print(platform.position)

func _get_configuration_warning() -> String:
	var text = ""
	var count : int = 0
	for i in get_children():
		if i is KinematicBody2D:
			count += 1
	
	if count != 1:
		if count > 1:
			text = "This node works only with one KinematicBody2D"
		else:
			text = "This node must contain at least one KinematicBody2D"
	
	return text

func _timer_timeout(timer : Timer):
	if Engine.editor_hint:
		set_physics_process(editor_processing)
	else:
		set_physics_process(true)
	timer.queue_free()

func has_point(pos:Vector2) -> bool:
	var to_return = [false, null]
	var size = get_size()
	var num = 0
	for i in positions:
		if num == 0:
			num += 1
			continue
		var rect2 : Rect2 = Rect2(i + global_position - size, size * 2)
		to_return[0] = rect2.has_point(pos)
		to_return[1] = num
		if to_return[0]:
			return to_return
		num += 1
	return to_return

func set_editor_process(val:bool) -> void:
	if Engine.editor_hint:
		editor_processing = val
		set_physics_process(editor_processing)
		for i in get_children():
			if i is Timer:
				i.queue_free()
			elif i is KinematicBody2D:
				i.position = Vector2.ZERO
