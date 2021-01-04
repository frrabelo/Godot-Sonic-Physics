extends Spatial

func _ready():
	$Rotation.play("Idle");

func spawn():
	$Scale.play("Spawn");

func unSpawn():
	$Scale.play_backwards("Spawn", -1);

