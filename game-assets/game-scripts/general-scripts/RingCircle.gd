extends Node2D
tool

export var scene : PackedScene
export var scene_offset : Vector2 = Vector2(8, 8) setget _set_scene_offset
export var radius : float = 5 setget _set_radius
export var object_count : int = 16 setget _set_object_count
export var rotate : bool = false setget _set_rotate
export var rotation_speed : float = 1.0
export var editor_process : bool = false setget _set_editor_process
export var default_angle : float = 0 setget _set_dangle
var process_angle

func _ready() -> void:
	if Engine.editor_hint:
		set_process(rotate && editor_process)
		return
	set_process(rotate)

func _set_object_count(val : int) -> void:
	val = max(val, 0)
	object_count = val
	_clear()
	_spawn_rings(val, default_angle)
	update()

func _set_radius (val : float) -> void:
	radius = val
	_update_rings_pos(default_angle)
	update()

func _set_scene_offset (val : Vector2) -> void:
	scene_offset = val
	_update_rings_pos(default_angle)
	update()

func _set_dangle( val : float) -> void:
	default_angle = val
	_update_rings_pos(default_angle)
	update()

func _clear() -> void:
	for i in get_children():
		i.queue_free()

func _set_rotate(val : bool) -> void:
	rotate = val
	if val:
		set_process(editor_process)
	else:
		set_process(false)
		_update_rings_pos(default_angle)

func _set_editor_process (val : bool) -> void:
	editor_process = val
	if !editor_process:
		_update_rings_pos(default_angle)
	if rotate:
		set_process(val)

func _spawn_rings(count : int, angle : float = 0) -> void:
	var container : Node2D = Node2D.new()
	container.name = "objContainer"
	container.position = Vector2.ZERO
	add_child(container)
	var angle_step = 2*PI
	var m_angle = angle
	for i in count:
		var scene_obj : Node2D = scene.instance(PackedScene.GEN_EDIT_STATE_INSTANCE)
		var direction = Vector2(cos(m_angle), sin(m_angle))
		var pos = (scene_offset + container.position) + (direction * radius)
		scene_obj.set_position(pos)
		container.add_child(scene_obj)
		m_angle += angle_step / object_count

func _update_rings_pos(angle : float) -> void:
	var angle_step = 2*PI
	var container : Node2D
	for i in get_children():
		if i.name == "objContainer":
			container = i
			break
	if !container || (container && container.get_child_count() < 1):
		return
	#print(container.get_children())
	for i in container.get_children():
		var direction = Vector2(cos(angle), sin(angle))
		var pos = (scene_offset + container.position) + (direction * radius)
		i.set_position(pos)
		angle += angle_step/object_count
	process_angle = default_angle

func _process(delta: float) -> void:
	process_angle += delta * rotation_speed
	var angle_step = 2 * PI
	for i in get_child(0).get_children():
		var direction = Vector2(cos(process_angle), sin(process_angle))
		var pos = scene_offset + direction * radius
		i.position = pos
		process_angle += angle_step / object_count


func _draw() -> void:
	if Engine.editor_hint:
		draw_circle(Vector2.ZERO, radius, Color(0.0, 1.0, .5, 0.5))
