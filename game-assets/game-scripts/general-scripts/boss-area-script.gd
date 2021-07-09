extends Area2D
class_name BossArea
tool

var default_cam_limit : Dictionary = {
	"limit_left": 0,
	"limit_top": 0,
	"limit_right": 0,
	"limit_bottom": 0,
}
var rect_size : RectManipulate2D

func _enter_tree() -> void:
	if Engine.editor_hint:
		update_configuration_warning()

func _ready() -> void:
	if !Engine.editor_hint:
		rect_size = Utils.get_node_by_type(self, "RectManipulate2D")
		var size_shape = rect_size.get_rectshape_2d()
		var cs : CollisionShape2D = CollisionShape2D.new()
		cs.shape = size_shape.shape
		cs.position = size_shape.position
		rect_size.set_visible(false)

var players = []
var bosses : Array
func _on_BossArea_body_shape_entered(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	if bosses.size() <= 0:
		return
	if body.is_class("PlayerPhysics"):
		pass
		var p : PlayerPhysics = body
		if p.player_camera:
			var pc : PlayerCamera = p.player_camera
			pc.camera.limit_left
			players.append(p);

func _on_BossDied(node_id) -> void:
	pass

func _reset_PlayerCamera() -> void:
	for i in players:
		var p : PlayerPhysics = i
		var pc : PlayerCamera = p.player_camera
		
func _on_BossArea_body_shape_exited(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	if !bosses.size() <= 0:
		_reset_PlayerCamera()

func _get_configuration_warning() -> String:
	var to_return : String
	
	var manipulate = Utils.get_node_by_type(self, "RectManipulate2D")
	
	if !manipulate:
		to_return += "BossArea must have RectManipulate2D"
	return to_return

func get_class() -> String:
	return "BossArea"

func is_class(val : String) -> bool:
	return val == get_class() || .is_class(val)
