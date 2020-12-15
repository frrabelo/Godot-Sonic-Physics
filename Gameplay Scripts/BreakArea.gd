extends Node2D
const block_scene = preload("res://Test Zone/Braked.tscn");
export var breakingSound:AudioStream;
onready var hitBox = $"Body/HitBox"
onready var player = $"../../Player"
var min_speed = 270;
func spawnBlock(pos:Vector2, speed:Vector2, body):
	
	var block = block_scene.instance(PackedScene.GEN_EDIT_STATE_MAIN);
	add_child(block);
	block.speed = speed;
	block.set("position", pos);

func spawnMultiBlock(body, args:Array):
	for i in args:
		spawnBlock(\
			i["pos"],\
			i["speed"],\
			body
		)

func _on_BreakArea_body_entered(body):
	if body.name == 'Player':
		if body.is_grounded:
			if (body.is_rolling):
				if body.gsp > min_speed || body.gsp < -min_speed:
					removeChildren();
					var player = AudioStreamPlayer.new();
					player.stream = breakingSound;
					add_child(player)
					player.play()
					var speed_gsp_gt = int (body.gsp > 0);
					var speed_gsp_lt = int (body.gsp < 0);
					var gsp = body.gsp;
					var speedXL = body.gsp - (speed_gsp_lt * 30);
					var speedXG = body.gsp + (speed_gsp_gt * 30);
					spawnMultiBlock(\
						body,\
						[
							{
								"pos": Vector2(-8, -16),
								"speed": Vector2(speedXL, -250),
							},
							{
								"pos": Vector2(8, -16),
								"speed": Vector2(speedXG, -250),
							},
							{
								"pos": Vector2(-8, 0),
								"speed": Vector2(speedXL, -200),
							},
							{
								"pos": Vector2(8, 0),
								"speed": Vector2(speedXG, -200),
							},
							{
								"pos": Vector2(-8, 16),
								"speed": Vector2(speedXL, -150),
							},
							{
								"pos": Vector2(8, 16),
								"speed": Vector2(speedXG, -150),
							},
						]
					)
	pass

func removeChildren():
	var children = get_children();
	for i in children:
			remove_child(i);
	

func _on_BreakingSound_finished():
	get_parent().remove_child(self);

func _ready():
	set_process(true);

func _process(delta):
	hitBox.disabled = \
	(player.gsp > min_speed || player.gsp < -min_speed) &&\
	player.is_rolling;
