extends Spatial

onready var sig : MeshInstance = $Sign
var speed : float = 0

func _ready():
	set_process(speed > 0)

func _process(delta):
	if abs(speed) > 0:
		speed -= delta * sign(speed)
	else:
		set_process(false)
	sig.rotate_y(speed * delta)


func _on_Area2D_body_entered(body):
	if body.is_class('PlayerPhysics'):
		var player : PlayerPhysics = body
		#print(speed)
		speed += player.speed.x*0.03
		set_process(true)
