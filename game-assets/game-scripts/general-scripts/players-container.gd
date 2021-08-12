extends Node
onready var selected
export(NodePath) var main_player

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
			player.left_ground.add_exception(e)
			player.right_ground.add_exception(e)
			player.middle_ground.add_exception(e)
	set_main_player(get_node_or_null(main_player))
	

func set_main_player(child : PlayerPhysics):
	if main_player:
		selected = child.get_index()
		print(selected)
		child.im_main_player = true

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_released('ui_end'):
		get_node(main_player).im_main_player = false
		selected += 1
		print(selected)
		selected = (selected % get_child_count())
		var child = get_child(selected)
		main_player = child.get_path()
		set_main_player(child)
