extends ItemBox

func _action(player : PlayerPhysics) -> void:
	var sound:AudioPlayer = player.get_node("AudioPlayer");
	sound.play('ring')
	get_tree().current_scene.rings += 10 
