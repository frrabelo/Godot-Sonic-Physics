tool
extends Node2D

export var loop_sprite:Array = [
	load("res://Assets/Sprites/TileSets/Template Tileset/chr006.png"),
	load("res://Assets/Sprites/TileSets/Template Tileset/chr007.png"),
	load("res://Assets/Sprites/TileSets/Template Tileset/chr008.png")
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
		$Body.set_collision_layer_bit(0, false);
		$Body.set_collision_layer_bit(1, false);
		$Body.set_collision_layer_bit(2, false);
		$Body.set_collision_layer_bit(collision_layer, true);

func getLoop():
	return collision_layer;
