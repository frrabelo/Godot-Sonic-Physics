extends ButtonSelector
tool

var base_margin = 0
export var separation : int = 0 setget _set_separation
export var x_pivot : float = 0.0 setget _set_x_pivot
export var diagonal : int = 0 setget _set_diagonal
var diagonal_min : int = 0 setget _set_diagonal_min
var diagonal_max : int = 0
export(NodePath) var tween_path
onready var tween_animation : Tween = get_node(tween_path)

func _ready():
	diagonal_max = get_child(0).rect_size.y + separation * 14
	var lc = get_child(get_child_count()-1)
	diagonal_min = lc.get_position_in_parent() * -lc.rect_size.y-15
	diagonal = diagonal_max
	print(diagonal_min, '  ', diagonal_max)

func _set_selected(val : int) -> void:
	var length = get_child_count()-1
	val = max(0, min(length, val))
	if val == selected || all_disabled:
		return
	while get_child(val).disabled:
		val += (-sign(selected-val))
		if val < 0 || val >= length:
			return
	get_child(selected).anim_player.play("reset")
	selected = max(0, min(val, length))
	var selected_child:TextureButton = get_child(selected)
	selected_child.anim_player.play("click")
	var step = diagonal_max - ((selected) * (separation + selected_child.rect_size.y))
	var final_value = min(diagonal_max, max(diagonal_min, step))
	if tween_animation.is_active():
		tween_animation.stop_all()
	tween_animation.interpolate_property(self, @"diagonal", diagonal, final_value, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween_animation.start()
	global_sounds.play("MenuBleep")
	#print(diagonal)
	#print(scroll_vertical)

func _input(event):
	if event.is_pressed():
		if event.is_action_pressed("ui_down") || event.is_action_pressed("ui_up"):
			var updown_strength = -event.get_action_strength("ui_up") + event.get_action_strength("ui_down")
			_set_selected(selected + updown_strength)
		if event.is_action_pressed("ui_accept"):
			select_mode(get_child(selected))



func _get_minimum_size():
	return Vector2(10, 10)

func _notification(what):
	match what:
		_:
			_queue_sort()

func _queue_sort():
	if get_child_count() <= 0:
		return
	for i in get_children():
		var tb : TextureButton = i
		var rect : Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)
		rect.size = tb.texture_normal.get_size()
		rect.position.y = (tb.get_position_in_parent()) * (tb.rect_size.y + separation) + diagonal
		rect.position.x = (-rect.position.y + rect.size.x/2) + (x_pivot)
		fit_child_in_rect(i, rect)

func _set_x_pivot(val : float) -> void:
	x_pivot = val
	_queue_sort()

func _set_separation(val : int) -> void:
	separation = val
	_queue_sort()

func _set_diagonal(val : int) -> void:
	diagonal = max(diagonal_min, min(diagonal_max, val))
	_queue_sort()

func _set_diagonal_min(val : int) -> void:
	diagonal_min = val
	if diagonal_min > diagonal:
		_set_diagonal(diagonal_min)
