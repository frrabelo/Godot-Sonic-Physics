tool
extends Node2D

export var loop_sprite:Array = [
	load("res://game-assets/game-sprites/levels-sprites/test-zone-assets/tileset/chr006.png"),
	load("res://game-assets/game-sprites/levels-sprites/test-zone-assets/tileset/chr007.png"),
	load("res://game-assets/game-sprites/levels-sprites/test-zone-assets/tileset/chr008.png")
]

export(int) var collision_layer=0 setget setLoop, getLoop;

func setLoop(value:int):
	if value >= 0:
		collision_layer = value % 3;
	else:
		collision_layer = 2;
	if $Body/Sprite != null && loop_sprite[collision_layer]:
		$Body/Sprite.texture = loop_sprite[collision_layer]
	if $Body != null:
		for i in range(0, 3):
			$Body.set_collision_layer_bit(i, false);
			$Body.set_collision_mask_bit(i, false);
		$Body.set_collision_layer_bit(collision_layer, true);
		$Body.set_collision_mask_bit(collision_layer, true);
func getLoop():
	return collision_layer;
