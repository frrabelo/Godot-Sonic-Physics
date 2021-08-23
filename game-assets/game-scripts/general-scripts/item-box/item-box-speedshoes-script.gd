extends ItemBox

func _action(player : PlayerPhysics) -> void:
	player.speed_shoes = true
	var timer = Timer.new()
	timer.connect('timeout', self, '_speed_timeout', [timer, player])
	add_child(timer)
	timer.start(5)

func _speed_timeout(val:Timer, player:PlayerPhysics) -> void:
	val.queue_free()
	player.speed_shoes = false
