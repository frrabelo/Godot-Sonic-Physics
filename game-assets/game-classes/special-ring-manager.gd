extends Node2D

onready var visual3D = $"ViewportContainer/3DVisual"
onready var visual2D = $"Visual"

func _on_OpenTrigger_screen_entered() -> void:
	visual3D.get_node("EmeraldRing").spawn();


func _on_OpenTrigger_screen_exited() -> void:
	visual3D.get_node("EmeraldRing").unSpawn();
