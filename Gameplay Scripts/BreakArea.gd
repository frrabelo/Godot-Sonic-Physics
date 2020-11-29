extends StaticBody2D
const block_scene = preload("res://Test Zone/Braked.tscn");
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
	var min_speed = 270;
	print ("entered")
	if body.name == 'Player':
		print ('is_player');
		if body.fsm.current_state == 'OnGround':
			print ("is_on_ground");
			print(body.animation.current_animation);
			if (body.animation.current_animation == "Jumping_Rolling"):
				print("ir_rolling")
				if body.gsp > min_speed || body.gsp < -min_speed:
					print ("is_above_%s" % min_speed)
					removeChildren();
					var speed_gsp_gt = int (body.gsp > 0);
					var speed_gsp_lt = int (body.gsp < 0);
					var gsp = body.gsp;
					var speedXL = gsp - speed_gsp_lt * 30;
					var speedXG = gsp + speed_gsp_gt * 30;
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
			

func removeChildren():
	var children = get_children();
	print (children);
	for i in children:
		remove_child(i);
	
