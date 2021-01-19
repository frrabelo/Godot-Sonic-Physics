extends Node2D

onready var visual3D = $"ViewportContainer/3DVisual"
onready var visual2D = $"Visual"

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		visual3D.get_node("EmeraldRing").spawn();


func _on_Area2D_body_exited(body):
	if body.name == "Player":
		visual3D.get_node("EmeraldRing").unSpawn();
		
