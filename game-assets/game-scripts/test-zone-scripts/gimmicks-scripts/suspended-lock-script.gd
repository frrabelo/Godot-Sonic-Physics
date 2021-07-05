extends Area2D
tool

enum Lock {
	LEFT=0, RIGHT=1, BOTH=2
}

export(Lock) var lock:int = 0 setget _set_lock

func _on_SuspendedLock_body_shape_entered(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	if body is PlayerPhysics:
		var p : PlayerPhysics = body
		#print(lock == Lock.LEFT || lock == Lock.BOTH)
		if lock == Lock.LEFT:
			p.suspended_can_left = false
		elif lock == Lock.RIGHT:
			p.suspended_can_right = false
		else:
			p.suspended_can_left = false
			p.suspended_can_right = false
		print(p.suspended_can_left, p.suspended_can_right)


func _on_SuspendedLock_body_shape_exited(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	if body is PlayerPhysics:
		var p : PlayerPhysics = body
		if lock == Lock.LEFT:
			p.suspended_can_left = true
		elif lock == Lock.RIGHT:
			p.suspended_can_right = true
		else:
			p.suspended_can_left = true
			p.suspended_can_right = true
		
		print(p.suspended_can_left, p.suspended_can_right)

func _set_lock(val : int) -> void:
	lock = val
	modulate = {
		Lock.LEFT: Color(0, 1, 0.5),
		Lock.RIGHT: Color(0, 0.5, 1),
	}[lock]
