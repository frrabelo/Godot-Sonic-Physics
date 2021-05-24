tool
extends EditorPlugin

var selected_obj
var popup : PopupMenu

func handles(object: Object) -> bool:
	selected_obj = object
	return true

func forward_canvas_gui_input(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		var click : InputEventMouseButton = event
		if click.button_index == BUTTON_RIGHT && click.is_pressed():
			popup = preload('res://addons/EditorClicks/popup.res').instance(PackedScene.GEN_EDIT_STATE_MAIN)
			add_child(popup)
			popup.set_global_position(click.position)
			popup.connect('id_pressed', self, "click_item")
			popup.popup()
			update_overlays()
			return true
		if popup:
			if click.button_index != BUTTON_MIDDLE && !click.is_pressed():
				popup.queue_free()
				popup = null
	return false

func click_item(id : int) -> void:
	pass
	match id:
		0:
			pass
