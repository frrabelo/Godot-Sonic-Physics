extends Node2D
tool
onready var rocket : Node2D = $Rocket
onready var sonic_sprite = $Rocket/RocketSprite/SnappedSonic
onready var rocket_hit_box = $Rocket/RocketHitBox
onready var sonic_hit_box = $Rocket/SonicHitBox
onready var animator : AnimationPlayer = $Rocket/RocketSprite/RocketAnimator
onready var wick : AnimatedSprite = $Rocket/RocketSprite/Wick
export var distance : float = 3.0 setget _set_distance
export var acceleration : float = 100 setget _set_acceleration
export var delay_ascend : float = 0.5
export var max_speed : float = 100 setget _set_max_speed
export var can_control : bool = true setget _set_can_control
var can_ascend = false
var puff : PackedScene = preload('res://general-objects/dusts/boss-puff.tscn')
var speed : float = 0.0
var player : PlayerPhysics
var press_direction : int = 0

signal exploded

func _ready() -> void:
	set_process(false)
	set_process_input(false)
	if !Engine.editor_hint:
		animator.play('Idle')

func play_sounds (stream_player, audio : AudioStream, loop : bool = false):
	#var stream_player : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	if !stream_player.is_inside_tree():
		rocket.add_child(stream_player)
		stream_player.connect('finished', self, 'temp_stream_finish', [stream_player])
	stream_player.set_stream(audio)
	stream_player.set_autoplay(loop)
	stream_player.play(0)

func _set_max_speed(val : float) -> void:
	max_speed = val
	update()

func _set_can_control(val : bool) -> void:
	can_control = val
	var shade = get_node_or_null('Rocket/RocketSprite/ShaderPos')
	if shade:
		shade.set_visible(!val)
	update()

func _process(delta: float) -> void:
	if Engine.editor_hint:
		return
	
	if player:
		player.player_camera.follow_player = false
		player.player_camera.global_position += -(player.player_camera.global_position - rocket.global_position) * delta * 10
		player.control_locked = true
		player.control_unlock_timer = 0.1
		player.global_position = rocket.global_position
		player.set_visible(false)
		player.has_jumped = true
		player.fsm.change_state('OnAir')
	
	if !can_ascend:
		rocket.rotation = 0
		return
	if can_control:
		rocket.rotation += 0.75 * press_direction * delta
	var direction = Vector2(sin(rocket.rotation), -cos(rocket.rotation))
	if speed < max_speed:
		speed += delta*acceleration
	speed = min(max_speed, speed)
	if player:
		player.speed = direction * speed
	rocket.position += direction * speed * delta
	if rocket.position.length() > (Vector2(sin(rocket.rotation), cos(rocket.rotation)) * distance).length():
		_explode()

func _input(event: InputEvent) -> void:
	if !can_ascend && !can_control:
		press_direction = 0
		return
	press_direction =  (-Input.get_action_strength('ui_left') + Input.get_action_strength('ui_right'))

func _explode() -> void:
	emit_signal('exploded')
	# Reset the rocket
	set_process(false)
	set_process_input(false)
	can_ascend = false
	if player.player_camera:
		player.player_camera.follow_player = true
	speed = 0.0
	rocket.rotation = 0
	animator.play('Idle')
	
	# Explosion Effects
	get_tree().get_current_scene().get_node('HUD').flash_screen(0.1, 0.85)
	play_sounds(AudioStreamPlayer2D.new(), preload('res://game-assets/audio/sfx/Explosion3.wav'), false)
	var explosion = preload('res://zones/test-zone-objects/act-1-exclusive/rocket-explosion.tscn')
	var speeds = [
		Vector3(-200, -450, 0),
		Vector3(50, -500, 150),
		Vector3(200, -450, 0),
		Vector3(-50, -500, -100),
	]
	var obj = explosion.instance()
	obj.global_position = rocket.global_position
	obj.spawn_sphere(speeds)
	get_parent().add_child(obj)
	rocket.position = Vector2.ZERO
	if player:
		player.set_visible(true)
		player = null
		animator.play('Idle')

func _set_distance(val : float) -> void:
	distance = val
	update()

func _set_acceleration (val : float) -> void:
	acceleration = val
	update()

func _start_ascend(val : Timer) -> void:
	play_sounds($Rocket/Audios, load('res://game-assets/audio/sfx/test-zone/act-1/RocketBurn.wav'), true)
	animator.play('Ascending')
	animator.playback_speed = 2.5
	can_ascend = true
	var timer = Timer.new()
	timer.connect('timeout', self, '_repeat_spawn', [timer])
	add_child(timer)
	timer.start(0.1)
	wick.set_visible(false)
	val.queue_free()

func _repeat_spawn (val : Timer):
	if !is_processing():
		val.queue_free()
		return
	var puff_obj : AnimatedSprite = puff.instance()
	puff_obj.rotation = rocket.rotation
	add_child(puff_obj)
	puff_obj.global_position = ($Rocket/SpawnPuff.global_position)
	val.start(((speed/max_speed)) * 4 * get_process_delta_time())

func _draw() -> void:
	if Engine.editor_hint:
		var acc_media = acceleration 
		if can_control:
			draw_arc($Rocket.position, distance, 0, PI*2, 360, Color(1, 0.5, 0.5, 0.5), 7.5)
		else:
			draw_line($Rocket.position, Vector2($Rocket.position.x, -distance), Color(1, .5, .5, .5), 3, true)

func _get_collision_point(body) -> Vector2:
	var main_collider : Area2D = rocket_hit_box
	var collision_points : Vector2 = (body.global_position - main_collider.global_position) / 2
	return collision_points


func _on_Snap_body_shape_entered(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	match body.get_class():
		"PlayerPhysics":
			if !player:
				player = body
				var timer : Timer = Timer.new()
				timer.connect('timeout', self, '_start_ascend', [timer])
				add_child(timer)
				timer.start(delay_ascend)
				animator.play('WickBurning')
				sonic_sprite.scale.x = -sign(player.global_position.x - global_position.x)
				sonic_hit_box.position = sonic_sprite.offset * sonic_sprite.scale.x
				sonic_sprite.get_node('SsAnimator').play('snapped-sonic')
				play_sounds($Rocket/Audios, load('res://game-assets/audio/sfx/grab.wav'))
				set_process(true)
				if can_control:
					set_process_input(true)
				return
		"TileMap":
			var tmap : TileMap = body
			var cell = tmap.get_cellv(tmap.world_to_map(_get_collision_point(body)))
			var tile = tmap.get_tileset().tile_get_shape_one_way(cell, local_shape)
			if tile:
				return
		"CollisionObject2D":
			var co2D : CollisionObject2D = body
			var shape_oneway : bool = co2D.get_shape_owner_one_way_collision_margin(body_shape)
			if shape_oneway :
				return
	if is_processing() && can_ascend:
		_explode()

func temp_stream_finish(st) -> void:
	st.queue_free()

func get_class():
	return "Rocket"

func is_class(val : String) -> bool:
	return val == get_class() || .is_class(val)
