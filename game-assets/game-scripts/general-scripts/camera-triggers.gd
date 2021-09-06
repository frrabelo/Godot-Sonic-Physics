extends Area2D
class_name CameraTrigger

export(Vector2) var cam_offset
export(Vector2) var position_when_not_following
export(Vector2) var move_cam
export(bool) var animate_enter = false
export(bool) var animate_exit = false
export(float) var animations_duration = 0.5
export(bool) var follow_player
export(bool) var follow_left
export(bool) var follow_right
export(bool) var follow_up
export(bool) var follow_down
export(bool) var reset_when_exit = false
var prev_state = []
func _ready() -> void:
	connect('body_shape_entered', self, '_player_entered')
	connect('body_shape_exited', self, '_player_exited')

func _player_entered(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	if body.is_class('PlayerPhysics'):
		var player : PlayerPhysics = body
		if !player.im_main_player:
			return
		var camera : PlayerCamera = get_tree().get_current_scene().get_node('PlayerCamera')
		prev_state = [
			camera.follow_player, camera.followLeft, camera.followRight,
			camera.followUp, camera.followDown, camera.horizontal_offset,
			camera.vertical_offset, camera.position
		]
		camera.follow_player = follow_player
		camera.followLeft = follow_left
		camera.followRight = follow_right
		camera.followUp = follow_up
		camera.followDown = follow_down
		if !animate_enter:
			camera.horizontal_offset = cam_offset.x
			camera.vertical_offset = cam_offset.y
			if !follow_player:
				camera.position = position + position_when_not_following
			position_when_not_following += move_cam
		else:
			var tween: Tween = Tween.new()
			tween.interpolate_property(camera, 'horizontal_offset', camera.horizontal_offset, cam_offset.x, animations_duration)
			tween.interpolate_property(camera, 'vertical_offset', camera.vertical_offset, cam_offset.y, animations_duration)
			if move_cam.x != 0:
				tween.interpolate_property(camera, 'position:x', camera.position.x, camera.position.x + move_cam.x, animations_duration)
			if move_cam.y != 0:
				tween.interpolate_property(camera, 'position:y', camera.position.y, camera.position.y + move_cam.y, animations_duration)
			if !follow_player:
				tween.interpolate_property(camera, 'position', camera.position, position + position_when_not_following, animations_duration)
			tween.connect('tween_all_completed', self, '_animation_ended', [tween])
			add_child(tween)
			tween.start()

func _animation_ended(tween:Tween) -> void:
	tween.queue_free()

func _player_exited(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	if body.is_class('PlayerPhysics'):
		var player : PlayerPhysics = body
		if !player.im_main_player:
			return
		var camera : PlayerCamera = get_tree().get_current_scene().get_node('PlayerCamera')
		if reset_when_exit:
			camera.follow_player = true
			camera.followLeft = true
			camera.followRight = true
			camera.followUp = true
			camera.followDown = true
			if !animate_exit:
				camera.horizontal_offset = 0.0
				camera.vertical_offset = 0.0
			else:
				var tween = Tween.new()
				tween.interpolate_property(camera, 'horizontal_offset', camera.horizontal_offset, 0.0, animations_duration)
				tween.interpolate_property(camera, 'vertical_offset', camera.vertical_offset, 0.0, animations_duration)
				tween.connect('tween_all_completed', self, '_animation_ended', [tween])
				add_child(tween)
				tween.start()
			return
