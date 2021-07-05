tool
extends Node2D
class_name CircleObjects

export var scene : PackedScene = preload('res://general-objects/spring-object.tscn')
export var scene_offset : Vector2 = Vector2(8, 8) setget _set_scene_offset
export var radius : float = 50 setget _set_radius
export var object_count : int = 16 setget _set_object_count
export var blank_position = "" setget _set_blank_positions
export var rotate : bool = false setget _set_rotate
export var rotation_speed : float = 1.0
export var editor_process : bool = false setget _set_editor_process
export var default_angle : float = 0 setget _set_dangle
var process_angle = default_angle

func _ready() -> void:
	if Engine.editor_hint:
		set_physics_process(rotate && editor_process)
		return
	set_physics_process(rotate)

func _set_object_count(val : int) -> void:
	val = max(val, 0)
	object_count = val
	_spawn_objects(val, default_angle, blank_position)
	update()

func _set_blank_positions(val : String) -> void:
	blank_position = val
	_spawn_objects(object_count, default_angle, blank_position)
	update()

func _set_radius (val : float) -> void:
	radius = val
	if !editor_process:
		_update_rings_pos(default_angle)
	update()

func _set_scene_offset (val : Vector2) -> void:
	scene_offset = val
	if !editor_process:
		_update_rings_pos(default_angle)
	update()

func _set_dangle( val : float) -> void:
	default_angle = val
	if !editor_process:
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
		set_physics_process(val)

func _spawn_objects(count : int, angle : float = 0, blanks : String = "") -> void:
	_clear()
	var container = Node2D.new()
	container.name = "objContainer"
	container.position = Vector2.ZERO
	add_child(container)
	var angle_step = 2*PI
	var m_angle = angle
	for i in count:
		if blank_position.length() > i && blank_position[i] == "0":
			m_angle += angle_step / object_count
			var obj : Node2D = Node2D.new()
			obj.position = Vector2.RIGHT.rotated(angle)
			container.add_child(obj)
			continue
		var scene_obj : Node2D = scene.instance(PackedScene.GEN_EDIT_STATE_INSTANCE)
		var direction = Vector2(cos(m_angle), sin(m_angle))
		var pos = (scene_offset + container.position) + (direction * radius)
		if scene_obj != null:
			scene_obj.set_position(pos)
			container.add_child(scene_obj)
		m_angle += angle_step / object_count

func _update_rings_pos(angle : float) -> void:
	var angle_step = 2*PI
	var container : Node2D
	if get_child_count() > 0:
		container = get_child(0)
	if !container || (container && container.get_child_count() < 1):
		return
	#print(container.get_children())
	var b : int = 0
	for i in container.get_children():
		#print(b < blank_position.length() && blank_position[b] == "0")
		if b < blank_position.length() && blank_position[b] == "0":
			b += 1
			angle += angle_step/object_count
			continue
		var direction = Vector2(cos(angle), sin(angle))
		var pos = (scene_offset + container.position) + (direction * radius)
		i.set_position(pos)
		angle += angle_step/object_count
		b += 1
	process_angle = default_angle

func _physics_process(delta: float) -> void:
	if process_angle == null:
		process_angle = default_angle
		print(process_angle)
		return
	process_angle += delta * rotation_speed
	var p_angle : float = process_angle
	var angle_step : float = 2 * PI
	for i in get_child(0).get_children():
		var direction = Vector2(cos(p_angle), sin(p_angle))
		var pos = scene_offset + direction * radius
		i.position = pos
		p_angle += angle_step / object_count


func _draw() -> void:
	if Engine.editor_hint:
		var col = Color(.0, 1, 0.5, .5)
		#var circle = CircleShape2D.new()
		draw_circle(Vector2.ZERO, radius, col)

func _edit_is_selected_on_click(p_point:Vector2, p_tolerance:float) -> bool:
	var converted_cordinates = get_viewport().get_global_canvas_transform().affine_inverse().xform(p_point)
	return converted_cordinates.length() < radius + p_tolerance;
