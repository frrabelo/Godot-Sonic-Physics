extends Node2D

const SPHERE = preload('res://zones/test-zone-objects/act-1-exclusive/player-rocket-explosion-sphere.tscn')
const SPHERE_SCRIPT = preload('res://zones/test-zone-objects/act-1-exclusive/rocket-explosion-sphere.gd')
var all_spheres : Array = []

func _ready() -> void:
	set_process(false)

func spawn_sphere(speeds : PoolVector3Array) -> Array:
	for speed in speeds:
		var sp_object : SPHERE_SCRIPT = SPHERE.instance()
		sp_object.connect('explosion_gen_end', self, '_one_less', [sp_object])
		sp_object.position = Vector2.ZERO
		sp_object.speed = speed
		sp_object.z_as_relative = false
		add_child(sp_object)
		all_spheres.append(sp_object)
	
	return all_spheres

func _one_less(obj : SPHERE_SCRIPT) -> void:
	if all_spheres.size() > 0:
		all_spheres.remove(all_spheres.find(obj))
	if all_spheres.size() <= 0:
		if $Timer:
			$Timer.stop()
			if $Timer/AudioStreamPlayer:
				$Timer/AudioStreamPlayer.connect('finished', $Timer, 'queue_free')
		set_process(true)

func _process(delta: float) -> void:
	if get_child_count() <= 0:
		queue_free()

func _on_Timer_timeout() -> void:
	$Timer.wait_time += 0.0015
	$Timer.start()
	$Timer/AudioStreamPlayer.play()
