extends Area2D
class_name DamageBox2D

signal stay_inside(body)

var players_overlaps : Array = []

func _ready():
	set_physics_process(false)
	connect("body_entered", self, "_when_body_enter")
	connect("body_exited", self, "_when_body_exit")

func _when_body_enter(body : Node) -> void:
	if body is PlayerPhysics:
		players_overlaps.append(body)
		if players_overlaps.size() > 0:
			set_physics_process(true)

func _when_body_exit(body : Node) -> void:
	if body is PlayerPhysics:
		players_overlaps.remove(players_overlaps.find(body))
		if players_overlaps.size() <= 0:
			set_physics_process(false)

func _physics_process(delta):
	if players_overlaps.size() <= 0:
		set_physics_process(false)
		return
	for i in players_overlaps:
		var p : PlayerPhysics = i
		emit_signal("stay_inside", p)
