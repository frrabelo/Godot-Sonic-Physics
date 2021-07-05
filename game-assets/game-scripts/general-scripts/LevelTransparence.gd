extends Area2D
tool

var players : Array = []
export var fade_time:float = 0.5
export var tranparency_inside : float = 0.5

func _ready() -> void:
	set_process(false)
	if Engine.editor_hint:
		modulate.a = 0.5
		return
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

func _process(delta: float) -> void:
	#print(players, modulate.a)
	var t = delta / fade_time
	var side = Utils.sign_bool(players.size() <= 0)
	modulate.a += ((1.0 - tranparency_inside) * t) * side
	modulate.a = min (1.0, max(modulate.a, tranparency_inside))
	var processing : bool = (modulate.a >= 1.0 && side > 0) || (modulate.a <= tranparency_inside && side < 0)
	set_process(!processing)
