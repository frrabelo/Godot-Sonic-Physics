extends Node2D
tool

const egg_robo_dejects = preload("res://zones/test-zone-objects/act-1-exclusive/egg-robo-cart-destroyed.tscn")
const explosion_scene = preload("res://zones/test-zone-objects/act-1-exclusive/rocket-explosion.tscn")

var tile_size = 16
onready var cart : Area2D = $CartArea
onready var animator : AnimationPlayer = $Animator
onready var player_sprite : Sprite = cart.get_node("Player")
onready var traffic_animator = $TrafficLight/TrafficAnimator
export var delay_start : float = 0.5

export var max_speed : float = 2000.0
export var max_distance : float = 2000.0 setget set_max_distance
export var acceleration : float = 500 setget set_acceleration

func set_max_speed(e : float) -> void:
	max_speed = max(0, e)
	update()

func set_max_distance(e : float) -> void:
	max_distance = max(0, e)
	var stop_area = get_node_or_null("StopArea")
	if stop_area:
		stop_area.position.x = max_distance*tile_size + 13
	var pipe = get_node_or_null("Pipe")
	if pipe:
		pipe.region_rect = Rect2(Vector2.ZERO, Vector2(max_distance*tile_size+43, 8))
	update()

func set_acceleration(e : float) -> void:
	acceleration = max(0, e)


func _draw():
	draw_line(Vector2.ZERO, Vector2(max_distance*tile_size + 13, 0), Color(1.0, 0.0, 0.0, 0.5), 5.0, true)


func _on_CartArea_exploded():
	var dejects = egg_robo_dejects.instance()
	var explosions = explosion_scene.instance()
	dejects.linear_velocity.x = cart.speed
	var sphere_positions = []
	for i in 4:
		var angle = deg2rad(25) - deg2rad(25)*i
		sphere_positions.push_back(Vector3(cos(angle), sin(angle), 0) * cart.speed)
	add_child(dejects)
	add_child(explosions)
	dejects.position = cart.position
	explosions.position = cart.position
	explosions.spawn_sphere(sphere_positions)
