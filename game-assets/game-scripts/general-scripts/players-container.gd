extends Node

func _ready():
	var children = get_children()
	
	for p in children:
		for e in children:
			var player:PlayerPhysics = p as PlayerPhysics
			player.add_collision_exception_with(e)
			player.left_wall.add_exception(e)
			player.left_wall_bottom.add_exception(e)
			player.right_wall.add_exception(e)
			player.right_wall_bottom.add_exception(e)
		#	player.left_ground.add_exception(e)
		#	player.right_ground.add_exception(e)
		#	player.middle_ground.add_exception(e)
