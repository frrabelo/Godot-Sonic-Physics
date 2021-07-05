extends Node2D
tool
var players = []
var next
var prev
onready var coll = $Collision
var to_top : bool = false
var speed = 0.0

export var chain_size : float = 16.0 setget _set_chain_size
export var chain_length : int = 1 setget _set_chain_length
export var grab_position_from : float = 1.0 setget _set_grab_position_from
export var grab_position : float = 1.0 setget _set_grab_position
export var grab_position_to : float = 1.0
export var animation_duration : float = 1.0

func _ready() -> void:
	set_process(false)
	if !Engine.editor_hint:
		_set_grab_position(grab_position_from)

func _set_chain_size(val : float) -> void:
	chain_size = val
	update_grab ()

func _set_chain_length ( val : int ) -> void:
	chain_length = max(val, 0)
	update_grab ()

func _set_grab_position_from (val : float) -> void:
	grab_position_from = min(1.0, max(0.0, val))
	grab_position = grab_position_from
	update_grab ()

func _set_grab_position (val : float) -> void:
	grab_position = min(1.0, max(0.0, val))
	update_grab ()

func update_grab() -> void:
	var chain = get_node_or_null('Chain')
	var grab  = get_node_or_null('Collision')
	if chain && grab:
		var total_size = chain_size * chain_length
		chain.offset.y = -total_size/2
		chain.position.y = grab_position * (total_size)
		chain.region_rect = Rect2(Vector2(0, 0), Vector2(7, chain_length*chain_size))
		grab.position.y = (total_size * grab_position) + 20
		update()


func _on_Collision_body_shape_entered(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	if body is PlayerPhysics:
		var p : PlayerPhysics = body
		if p.suspended_jump:
			return
		players.append(p)
		if players.size() > 0:
			to_top = true
			p.fsm.change_state('Suspended')
			var grab = get_node_or_null('Collision')
			p.global_position = grab.global_position
			p.player_camera.followUp = false
			p.player_camera.followDown = false
			set_process(true)
			_set_players_props('suspended_can_left', false)
			_set_players_props('suspended_can_right', false)


func _on_Collision_body_shape_exited(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	if body is PlayerPhysics:
		var p : PlayerPhysics = body
		if p.suspended_jump:
			pass
			#p.suspended_jump = false
		p.player_camera.followUp = true
		p.player_camera.followDown = true
		players.remove(players.find(p))
		if players.size() <= 0:
			to_top = false
			set_process(true)

func _process(delta: float) -> void:
	var direction = -Utils.sign_bool(to_top)
	speed += direction*2 * delta
	_set_grab_position(grab_position + (speed * delta))
	var cameras_aligned = true
	if players.size() > 0:
		for n in players.size():
			if !players[n]:
				continue
			var p : PlayerPhysics = players[n]
			if p.fsm.current_state == "Suspended":
				p.global_position.y = coll.global_position.y
				if p.player_camera.global_position.y != p.global_position.y:
					p.player_camera.global_position.y += (p.global_position.y - p.player_camera.global_position.y) * delta * 10
			else:
				players.remove(n)
			cameras_aligned = cameras_aligned && p.player_camera.global_position.y != p.global_position.y
	
	if grab_position == float(!to_top):
		_set_players_props('suspended_can_left', true)
		_set_players_props('suspended_can_right', true)
		if cameras_aligned:
			set_process(false)
		speed = 0
	else:
		_set_players_props('suspended_can_left', false)
		_set_players_props('suspended_can_right', false)

func _set_players_props(prop: String, value) -> void:
	for i in players.size():
		if !players[i]:
			continue
		var p : PlayerPhysics = players[i]
		if p.fsm.current_state != "Suspended":
			players.remove(i)
			continue
		p.set(prop, value)
		
