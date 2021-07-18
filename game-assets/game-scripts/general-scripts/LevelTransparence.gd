extends Area2D
tool

var players : Array = []
export var editor_opacity : float = 0.5 setget _set_editor_opacity
export var visible_in_editor : bool = true setget _set_in_editor_visibility
export var fade_time:float = 0.5
export var tranparency_inside : float = 0.5

func _ready() -> void:
	set_process(false)
	if Engine.editor_hint:
		set_visible(visible_in_editor)
		modulate.a = editor_opacity
		return
	set_visible(true)
	modulate.a = 1.0

func _on_LevelTransparence_body_entered(body: Node) -> void:
	if body is PlayerPhysics:
		var player : PlayerPhysics = body
		players.append(player)
		set_process(true)


func _on_LevelTransparence_body_exited(body: Node) -> void:
	if body is PlayerPhysics:
		var player : PlayerPhysics = body
		if players.has(player):
			players.remove(players.find(player, 0))
			set_process(true)

func _set_editor_opacity(val : float) -> void:
	editor_opacity = max(0, min(1, val))
	modulate.a = editor_opacity

func _set_in_editor_visibility(val : bool) -> void:
	visible_in_editor = val
	set_visible(visible_in_editor)

func _process(delta: float) -> void:
	#print(players, modulate.a)
	var t = delta / fade_time
	var side = Utils.sign_bool(players.size() <= 0)
	modulate.a += ((1.0 - tranparency_inside) * t) * side
	modulate.a = min (1.0, max(modulate.a, tranparency_inside))
	var processing : bool = (modulate.a >= 1.0 && side > 0) || (modulate.a <= tranparency_inside && side < 0)
	set_process(!processing)
