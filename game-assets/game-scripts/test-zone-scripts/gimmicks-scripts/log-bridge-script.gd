extends Node2D
tool


onready var stackL:Sprite = $StackL
onready var stackR :Sprite = $StackR
onready var log_container :Node2D = $LogContainer
onready var ac_are : Area2D = $ActiveArea
onready var coll_s : CollisionShape2D = $ActiveArea/CollShape
export var length : int = 11 setget set_length
var default_y :float = 0.0

var sl:Sprite = get_node_or_null('StackL')
var sr:Sprite = get_node_or_null('StackR')
var lc:Node2D = get_node_or_null('LogContainer')
var ac:Area2D = get_node_or_null('ActiveArea')
var cl:CollisionShape2D = get_node_or_null('ActiveArea/CollShape')
var log_scene : PackedScene = preload('res://zones/test-zone-objects/act-all/log-object.tscn')
onready var logs = log_container.get_children()
var players : Array = []

func _enter_tree() -> void:
	sl = get_node_or_null('StackL')
	sr = get_node_or_null('StackR')
	lc = get_node_or_null('LogContainer')
	set_length(length)
	if Engine.editor_hint:
		set_process(false)

func _ready() -> void:
	if Engine.editor_hint:
		set_process(false)

func set_length(val : int) -> void:
	length = min(max(val, 6), 12)
	if sr:
		sr.position.x = (16*(length+1)-0.5)-10
		sr.position.y = 1.5
		if cl && ac:
			ac.position.x = sr.position.x / 2-11
			cl.shape.extents.x = sr.position.x/2
		update_logs()

func update_logs():
	for i in lc.get_children():
		i.queue_free()
	if lc:
		for i in length:
			var log_obj:Node2D = log_scene.instance()
			log_obj.position.x = (i * 16) + sr.get_texture().get_size().x-8-21
			log_obj.position.y = 0
			#print(log_obj.position)
			lc.add_child(log_obj)

func _process(delta: float) -> void:
	if Engine.editor_hint:
		set_process(false)
		return
	if players.size() <= 0:
		var count = 0
		for i in logs:
			i.position.y += -i.position.y * delta * 16
			if abs(i.position.y) < 0.05:
				count += 1
				i.position.y = 0
		if count == length:
			return
			set_process(false)
		return
	for o in players:
		var p:PlayerPhysics = o
		if !p.is_grounded:
			continue
		var curr = floor((p.position.x - position.x) / 16) + 1
		var max_dep
		if curr <= length/2:
			max_dep = curr * 2
		else:
			max_dep = ((length - curr) + 1) * 2
		for i in logs.size():
			var difference = abs((i+1) - curr)
			var log_distance
			if i < curr:
				log_distance = 1 - (difference / curr)
			else:
				log_distance = 1 - (difference / ((length - curr) + 1))
			logs[i].position.y += (floor(max_dep * sin((PI/2) * log_distance)) - logs[i].position.y) * delta * 16


func _on_ActiveArea_body_entered(body):
	if body.is_class('PlayerPhysics'):
		if players.has(body):
			return
		players.append(body)
		set_process(true)


func _on_ActiveArea_body_exited(body):
	if body.is_class('PlayerPhysics'):
		if players.has(body):
			players.remove(players.find(body))
