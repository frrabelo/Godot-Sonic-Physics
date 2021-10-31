extends Line2D
tool
onready var vp : Vector2 = get_viewport_rect().size
var editor_vp : Vector2 = Vector2(ProjectSettings.get("display/window/size/width"), ProjectSettings.get("display/window/size/height"))
export var initial_move:float = 0.0 setget _set_initial_move
export var speed : float = 2.0
export var range_y : float = 10
var moving = initial_move
var cvp = editor_vp
export var editor_process : bool setget _set_editor_process
func _enter_tree():
	cvp = editor_vp if Engine.editor_hint else vp
	set_process(true)
	if Engine.editor_hint:
		set_process(editor_process)
func _ready():
	get_tree().get_root().connect("size_changed", self, "reload_vp")
	set_process(true)
	if Engine.editor_hint:
		set_process(editor_process)
	cvp = editor_vp if Engine.editor_hint else vp
	print(cvp)

func reload_vp():
	vp = get_viewport_rect().size

func _process(delta):
	var poin = []
	moving += speed *delta
	moving = fmod(moving, TAU)
	var i = -0.01
	while i < 1.05:
		var v:Vector2 = Vector2.ZERO
		v.x = (cvp.x*i)
		v.y = cos(moving)*10
		poin.append(Vector2((v.x), cos(i*10 + moving)*range_y))
		i += 0.05
	points = poin

func _set_editor_process(val : bool):
	editor_process = val
	if Engine.editor_hint:
		set_process(editor_process)
	
func _set_initial_move(val : float):
	initial_move = val
	moving = initial_move
