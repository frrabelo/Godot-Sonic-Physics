extends Area2D
class_name BossArea
tool
onready var tween = $Tween
var default_cam_limit : Dictionary = {
	"limit_left": 0,
	"limit_top": 0,
	"limit_right": 0,
	"limit_bottom": 0,
}


var rect_size : CollisionShape2D

var pos

func _enter_tree() -> void:
	if Engine.editor_hint:
		update_configuration_warning()
		update()

func _ready() -> void:
	if !Engine.editor_hint:
		rect_size = Utils.get_node_by_type(self, 'CollisionShape2D')
		pos = {
			"limit_left": rect_size.global_position.x - rect_size.shape.extents.x,
			"limit_right": rect_size.global_position.x + rect_size.shape.extents.x,
			"limit_top": rect_size.global_position.y - rect_size.shape.extents.y,
			"limit_bottom": rect_size.global_position.y + rect_size.shape.extents.y,
		}

var players = []
var bosses : Array
func _on_BossArea_body_shape_entered(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	if bosses.size() <= 0:
		pass
	if body.is_class("PlayerPhysics"):
		pass
		var p : PlayerPhysics = body
		var pc : PlayerCamera = p.player_camera
		if pc:
			for i in default_cam_limit:
				default_cam_limit[i] = pc.camera.get(i)
				var sum = (sign(pos[i])* 200)
				match i:
					"limit_right", "limit_top":
						sum = -sum
				
				print(i, " ", pos[i])
				print(i, " ", pc.camera.get(i) - pos[i], " ", pc.camera.get(i))
				tween.interpolate_property(pc.camera, i, pos[i] - sum, pos[i], 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.0)
			#tween.interpolate_property(pc, "global_position:x", pc.global_position.x, global_position.x, 1.0, 0, Tween.EASE_OUT)
			#tween.interpolate_property(pc, "global_position:y", pc.global_position.y, global_position.y, 1.0, 0, Tween.EASE_OUT)
			tween.start()
			
			#pc.camera.limit_left = rect_size.global_position.x - rect.extents.x
			#pc.camera.limit_right = rect_size.global_position.x + rect.extents.x
			#pc.camera.limit_top = rect_size.global_position.y - rect.extents.y
			#pc.camera.limit_bottom = rect_size.global_position.y + rect.extents.y
			players.append(p);

func _on_BossDied(node_id) -> void:
	pass

func _reset_PlayerCamera() -> void:
	for i in players:
		var p : PlayerPhysics = i
		var pc : PlayerCamera = p.player_camera
		for prop in default_cam_limit:
			#print(prop)
			pc.camera.set(prop, default_cam_limit[prop])
func _on_BossArea_body_shape_exited(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	if bosses.size() <= 0:
		if players.size() <= 0:
			set_process(false)
		_reset_PlayerCamera()

func _get_configuration_warning() -> String:
	var to_return : String
	
	var manipulate = Utils.get_node_by_type(self, "RectManipulate2D")
	return to_return

func get_class() -> String:
	return "BossArea"

func is_class(val : String) -> bool:
	return val == get_class() || .is_class(val)

func _draw() -> void:
	if Engine.editor_hint:
		var color : Color = Color("#00ffff")
		var viewport = get_viewport().get_visible_rect()
		viewport.position -= viewport.size / 2
		#print(viewport.position)
		draw_rect(viewport, color, false, 2.0, true)
