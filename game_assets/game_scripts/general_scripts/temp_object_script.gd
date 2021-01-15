extends Node2D

export var node_path:String
onready var node:Node = get_node(node_path);

export var anim_name:String;

func _ready():
	if node is AnimatedSprite:
		var animated_sprite:AnimatedSprite = node;
		animated_sprite.play(anim_name, false)

func when_anim_ends():
	queue_free()
