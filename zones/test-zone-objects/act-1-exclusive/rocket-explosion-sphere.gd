extends AnimatedSprite

signal explosion_gen_end

const explosion = preload('res://general-objects/explosions/boss-explosion-object.tscn')
onready var timer : Timer = $Timer
var speed : Vector3 = Vector3(0, 0, 0)
const GRAV : float = 1000.0
var friction : float = 40
var z_pos = 0.0

func _ready() -> void:
	timer.connect('timeout', self, "_on_Timer_timeout", [timer])
	if speed.z == 0 || z_index == 0:
		z_index = 10

func _physics_process(delta: float) -> void:
	speed.x += -sign(speed.x) * delta
	speed.z += -sign(speed.z)*100 * delta
	speed.y += (GRAV + (speed.z*1.5)) * delta
	var vec2_speed:Vector2 = Vector2(speed.x, speed.y)
	position += vec2_speed * delta
	z_pos += (speed.z/100) * delta
	scale = Vector2.ONE * (z_pos + 1)
	scale = scale if scale > Vector2.ZERO else Vector2.ZERO
	z_index = int(z_pos*100)

func _on_ScreenSensor_screen_exited() -> void:
	var timer : Timer = Timer.new()
	timer.connect('timeout', self, 'queue_free_time', [timer])
	add_child(timer)
	timer.start()
	emit_signal('explosion_gen_end')

func queue_free_time(timer:Timer) -> void:
	timer.queue_free()
	queue_free()

func _on_Timer_timeout(timer : Timer) -> void:
	var explosion_obj : AnimatedSprite = explosion.instance()
	explosion_obj.position = position
	explosion_obj.z_index = z_index-1
	explosion_obj.z_as_relative = false
	explosion_obj.scale = scale
	get_parent().add_child(explosion_obj)
	timer.wait_time += 0.0015
	speed_scale -= 0.1
