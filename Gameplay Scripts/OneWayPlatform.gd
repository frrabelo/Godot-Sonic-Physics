extends Node2D

onready var player:PlayerPhysics = get_node("/root/main/Player");
onready var collide:CollisionShape2D = $BodyBlock/collideBlock

func _process(delta):
	if player != null:
		collide.disabled = \
			player.velocity.y < 0 ||\
			player.position.y + 20 > global_position.y + collide.shape.extents.y;


func _on_Area2D_body_entered(body):
	set_process(true);


func _on_Area2D_body_exited(body):
	set_process(false);
