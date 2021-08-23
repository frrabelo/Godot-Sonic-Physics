extends Node2D
class_name Breakable
export var block_scene:PackedScene;
onready var level = get_tree().get_current_scene().get_node_or_null('Level')
onready var global_sounds:AudioPlayer = get_node('/root/GlobalSounds')

func spawnBlock(pos:Vector2, speed:Vector2, body):
	var block:Node2D = block_scene.instance();
	block.speed = speed;
	block.position = global_position + pos;
	block.spawnpoint = block.position
	level.add_child(block)
