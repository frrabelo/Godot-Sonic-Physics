extends Node2D

onready var visual3D = $"3DVisual"
onready var visual2D = $"Visual"
func _ready():
	$Area2D.visible = false;
	var tdView = visual3D.get_texture();
	if tdView != null:
		visual2D.texture = tdView;

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		$"3DVisual/EmeraldRing".spawn();


func _on_Area2D_body_exited(body):
	if body.name == "Player":
		$"3DVisual/EmeraldRing".unSpawn();
		
