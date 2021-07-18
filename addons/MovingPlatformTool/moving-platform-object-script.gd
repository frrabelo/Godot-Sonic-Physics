tool
extends Node2D
class_name MovingPlatformObject

onready var path : Path2D = Utils.get_node_by_type(self, 'Path2D')

export var loop : bool = false setget set_loop
export var speed : float = 1.0
export var pause_timer : float = 1.0
export(bool) var editor_processing = false setget set_editor_process
onready var platform : KinematicBody2D = Utils.get_node_by_type(self, 'KinematicBody2D')
onready var positions = (path as Path2D).curve.get_baked_points()
var path_follow : PathFollow2D = PathFollow2D.new()
var remote_t : RemoteTransform2D = RemoteTransform2D.new()
var right : bool = false
var unit_pos = 0.0

func _enter_tree() -> void:
	if Engine.editor_hint:
		update_configuration_warning()

func _ready() -> void:
	if Engine.editor_hint:
		set_physics_process(editor_processing)
	else:
		if path:
			path_follow.rotate = false
			remote_t.set_remote_node((platform as KinematicBody2D).get_path())
			path.add_child(path_follow)
			path_follow.add_child(remote_t)
			path_follow.unit_offset= 0
		set_physics_process(true)
	#print(is_physics_processing())

func set_loop (val:bool) -> void:
	loop = val
	update()

func get_size() -> Vector2:
	var to_return : Vector2
	for i in get_children():
		if i is KinematicBody2D:
			for j in i.get_children():
				if j is CollisionShape2D:
					to_return = j.shape.extents
	
	return to_return

func _physics_process(delta: float) -> void:
	#print(int(right) * delta)
	unit_pos += Utils.sign_bool(right) * delta * speed
	unit_pos = max(0, min(1, unit_pos))
	path_follow.unit_offset = unit_pos
	if loop:
		if (path_follow.unit_offset >= 1 || path_follow.unit_offset <= 0):
			right = !right
			if pause_timer > 0.0:
				var timer = Timer.new()
				add_child(timer)
				timer.connect('timeout', self, '_timer_timeout', [timer])
				timer.start(pause_timer)
				set_physics_process(false)
	

func _get_configuration_warning() -> String:
	var text = ""
	var count_kin : int = 0
	var count_path : int = 0
	for i in get_children():
		if i is KinematicBody2D:
			count_kin += 1
		if i is Path2D:
			count_path += 1
	
	if count_kin != 1:
		if count_kin > 1:
			text = "This node works only with one KinematicBody2D"
		else:
			text = "This node must contain at least one KinematicBody2D"
	
	if count_path != 1:
		if count_path > 1:
			text = "This node works only with one Path2D"
		else:
			text = "This node must contain at least one Path2D"
	
	return text

func _timer_timeout(timer : Timer):
	if Engine.editor_hint:
		set_physics_process(editor_processing)
	else:
		set_physics_process(true)
	timer.queue_free()

func set_editor_process(val:bool) -> void:
	if Engine.editor_hint:
		editor_processing = val
		set_physics_process(editor_processing)
		for i in get_children():
			if i is Timer:
				i.queue_free()
			elif i is KinematicBody2D:
				i.position = Vector2.ZERO
