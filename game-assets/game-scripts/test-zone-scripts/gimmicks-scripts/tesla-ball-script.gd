extends Node2D
var players_rotations : Dictionary = {} setget set_players_rotations
onready var radius : float = 50
onready var plasma_sound : AudioStreamPlayer2D = $PlasmaSound

func _ready():
	if players_rotations.empty():
		set_physics_process(false)

func _on_TeslaBall_body_entered(body):
	if body is PlayerPhysics:
		body.fsm.change_state("Stateless")
		body.specific_animation_temp = true
		body.animation.animate("Rolling")
		players_rotations[body] = {
			"rotationR": -body.get_angle_to(global_position),
			"rotationZ": PI,
			"side": -1,
			"prev_position": null
		}
		play_plasma()
		if !players_rotations.empty():
			set_physics_process(true)


func _physics_process(delta):
	for player_node in players_rotations.keys():
		var player : PlayerPhysics = player_node
		var rots = players_rotations[player]
		
		var cos_zrotation = cos(rots["rotationZ"])
		var rad_zrot = radius * cos_zrotation
		rots["prev_position"] = player.position
		player.position.x = -cos(rots["rotationR"]) * rad_zrot
		player.position.y = sin(rots["rotationR"]) * rad_zrot
		
		rots["rotationR"] -= player.direction.x * delta * 2
		rots["rotationZ"] -= delta * 6.0
		rots["side"] = player.z_index
		if rots["rotationZ"] <= 0:
			rots["rotationZ"] = TAU
		player.z_index = 1 if rots["rotationZ"] < PI else -1
		player.position = (global_position - player.position) 

func set_players_rotations(val : Dictionary) -> void:
	players_rotations = val
	if players_rotations.empty():
		set_physics_process(false)

func play_plasma():
	if players_rotations.empty():
		return
	plasma_sound.play()
	get_tree().create_timer(0.5).connect("timeout", self, "play_plasma")
	
func _input(event):
	for i in players_rotations.keys():
		if Input.is_action_just_pressed("ui_jump_i%d" % i.player_index):
			var rots = players_rotations[i]
			var cos_zrotation = cos(rots["rotationZ"])
			var pos: Vector2 = ((rots["prev_position"] - global_position) - (i.position - global_position)) / radius * 12
			var rot = i.get_angle_to(global_position)
			i.speed.x = -i.JMP * pos.x
			i.speed.y = -i.JMP * pos.y
			i.fsm.change_state("OnAir")
			i.z_index = 1
			players_rotations.erase(i)
