extends ButtonSelector
tool
export(int, 1, 100, 1) var columns : int setget _set_columns
export var v_separation : int setget _set_v_separation
export var h_separation : int setget _set_h_separation
export var scroll_v : int = 0
export var scroll_h : int = 0

func _ready():
	pass

func _set_selected(val) -> void:
	var length = get_child_count()
	val = max(0, min(length-1, val))
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
	global_sounds.play("MenuBleep")

func _input(event):
	if event.is_pressed():
		var sel : int = selected
		if event.is_action_pressed("ui_down") || event.is_action_pressed("ui_up"):
			var ud_strength = -event.get_action_strength("ui_up") + event.get_action_strength("ui_down")
			var children = get_child_count()
			var rows = int(ceil(children/float(columns)))
			if (sel < children-(columns) && ud_strength > 0) || (sel >1 && ud_strength < 0): 
				_set_selected(sel + ud_strength*columns)
		if event.is_action_pressed("ui_left") || event.is_action_pressed("ui_right"):
			var lr_strength = -event.get_action_strength("ui_left") + event.get_action_strength("ui_right")
			if (sel % columns < columns-1 && lr_strength > 0) || (sel % columns > 0 && lr_strength < 0):
				_set_selected(selected + lr_strength)
		if event.is_action_pressed("ui_accept"):
			select_mode(get_child(selected))

func get_rows() -> int:
	return int(ceil(get_child_count()/float(columns)))

func _set_columns(val : int) -> void:
	columns = val
	_queue_sort()

func _set_v_separation(val : int) -> void:
	v_separation = val
	_queue_sort()

func _set_h_separation(val : int) -> void:
	h_separation = val
	_queue_sort()

func _notification(what):
	match what:
		_:
			_queue_sort()

func _queue_sort():
	var children_count = get_child_count()
	var row:int = -1;
	var my_min_rect : Vector2 = Vector2.ZERO
	for i in get_children():
		var c : Control = i
		var column_pos = c.get_position_in_parent() % columns
		if column_pos == 0:
			row += 1
		var rect : Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)
		rect.size = c.rect_size
		rect.position.x = (column_pos) * (rect.size.x + h_separation)
		rect.position.y = row * (rect.size.y + v_separation)
		fit_child_in_rect(c, rect)
		my_min_rect.y = max(my_min_rect.y, rect.position.y+rect.size.y)
		my_min_rect.x = max(my_min_rect.x, rect.position.x+rect.size.x)
	rect_min_size = my_min_rect
