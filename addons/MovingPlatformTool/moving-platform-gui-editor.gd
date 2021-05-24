tool
extends EditorPlugin

var obj : MovingPlatformObject
var dragging : bool = false
var anchor : int
var just_clicked = false
var click_position

func handles(object: Object) -> bool:
	if object is MovingPlatformObject:
		obj = object
		return true
	return false

func edit(object: Object) -> void:
	if obj && obj.is_visible():
		var node : Node = object
		var owner : Node = node.get_owner()
		print("edit: %s" % node.get_parent().get_path_to(node))

func drag_to(event_position: Vector2) -> void:
	var viewport_transformation_inv := obj.get_viewport().get_global_canvas_transform().affine_inverse()
	var viewport_position : Vector2 = viewport_transformation_inv.xform(event_position)
	var transform_inv := obj.get_global_transform().affine_inverse()
	var target_position : Vector2 = transform_inv.xform(viewport_position.round())
	if just_clicked:
		click_position = target_position - obj.positions[anchor]
		just_clicked = false
	obj.positions[anchor] = (target_position - click_position).round()

func forward_canvas_gui_input(event: InputEvent) -> bool:
	if !obj || !obj.is_visible():
		return false
	just_clicked = false
	var mouse_event_btn : InputEventMouseButton
	if event is InputEventMouseButton:
		mouse_event_btn = event
		if !mouse_event_btn.is_pressed():
			dragging = false
		if mouse_event_btn.is_pressed() && mouse_event_btn.button_index == BUTTON_LEFT:
			var point = obj.has_point(obj.get_global_mouse_position())
			if point[0]:
				if !dragging:
					just_clicked = true
				dragging = true
				var undo := get_undo_redo()
				undo.create_action("Move point")
				undo.add_undo_property(obj, "positions", obj.positions)
				undo.commit_action()
				anchor = point[1]
	if dragging:
		drag_to(event.position)
		obj.update()
		update_overlays()
		return true
	
	if Input.is_action_pressed('ui_cancel'):
		var undo = get_undo_redo()
		undo.commit_action()
		undo.undo()
	return false
