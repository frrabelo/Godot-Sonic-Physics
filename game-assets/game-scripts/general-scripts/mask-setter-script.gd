extends Area2D
tool

enum Switch { LEFT_TO_RIGHT, RIGHT_TO_LEFT, INVERT }
export(Switch) var SWITCH_MODE = Switch.LEFT_TO_RIGHT setget _set_switch_mode

var check_mask : int
var uncheck_mask : int

func _ready() -> void:
	if Engine.editor_hint:
		return
	connect('body_entered', self, '_on_Area2D_body_entered')

func left_to_right():
	if !Engine.editor_hint:
		check_mask = 2
		uncheck_mask = 1

func right_to_left():
	if !Engine.editor_hint:
		check_mask = 1
		uncheck_mask = 2

func invert(is_left_activated, is_right_activated):
	if !Engine.editor_hint:
		if is_left_activated :
			check_mask = 2
			uncheck_mask = 1
		elif is_right_activated :
			check_mask = 1
			uncheck_mask = 2

func _set_switch_mode(val):
	SWITCH_MODE = val
	update()

func _draw() -> void:
	match SWITCH_MODE:
		Switch.LEFT_TO_RIGHT:
			modulate = Color.red
			modulate.a = 0.5
		Switch.RIGHT_TO_LEFT:
			modulate = Color(0.1, 0.5, 0.7, 0.5)
		Switch.INVERT:
			modulate = Color.purple
			modulate.a = 0.5

func _on_Area2D_body_entered(body):
	if body.is_class("PlayerPhysics"):
		var player:PlayerPhysics = body as PlayerPhysics
		var left = player.get_collision_mask_bit(1)
		var right = player.get_collision_mask_bit(2)
		match SWITCH_MODE:
			Switch.LEFT_TO_RIGHT:
				left_to_right()
			Switch.RIGHT_TO_LEFT:
				right_to_left()
			Switch.INVERT:
				invert(left, right)
		#print(SWITCH_MODE)
		player.set_collision_mask_bit(check_mask, true)
		player.set_collision_mask_bit(uncheck_mask, false)
