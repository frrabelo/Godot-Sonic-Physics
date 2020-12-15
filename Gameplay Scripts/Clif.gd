extends Node2D

var timer:Timer;

func _on_Area_body_entered(body):
	if (body.name == "Player"):
		remove_child($Area);
		timer = Timer.new();
		add_child(timer);
		timer.start(0.5);
		timer.connect("timeout", self, "breakDown");

func breakDown():
	timer.stop();
	remove_child($StaticBody2D)
	timer = null;
	$BreakSound.play();
	spawn(Vector2(8, 0), 0.10);
	spawn(Vector2(-8, 0), 0.15);
	spawn(Vector2(24, 0), 0.20);
	spawn(Vector2(-24, 0), 0.25);

func spawn(pos: Vector2, delay:float = 0):
	var block:PackedScene = load("res://Test Zone/ClifPart.tscn");
	var blockInst:Node2D = block.instance(PackedScene.GEN_EDIT_STATE_INSTANCE);
	add_child(blockInst);
	blockInst.position = pos;
	blockInst.delay(delay);


func _on_BreakSound_finished():
	get_parent().remove_child(self);
