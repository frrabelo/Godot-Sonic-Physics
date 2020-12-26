tool
extends Node2D

export var loop_sprite:Array = [
	load("res://Sprites/TileSets/Template Tileset/chr006.png"),
	load("res://Sprites/TileSets/Template Tileset/chr007.png"),
	load("res://Sprites/TileSets/Template Tileset/chr008.png")
]

export(int) var type_loop=0 setget setLoop, getLoop;

func setLoop(value:int):
	if value >= 0:
		type_loop = value % 3;
	else:
		type_loop = 2;
	if $Body/Sprite != null:
		$Body/Sprite.texture = loop_sprite[type_loop]
	if $Body != null:
		$Body.set_collision_layer_bit(0, false);
		$Body.set_collision_layer_bit(1, false);
		$Body.set_collision_layer_bit(2, false);
		$Body.set_collision_layer_bit(type_loop, true);

func getLoop():
	return type_loop;
