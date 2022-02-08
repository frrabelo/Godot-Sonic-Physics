extends Node
export var current_menu: NodePath = "CurrentMenu/Main"

signal loaded
signal changed

func _ready():
	get_node(current_menu).owner = self
	update()

func load_scene(scene_path:String = ""):
	var transition = $Top/Transition
	transition.play("In")
	yield(transition, "animation_finished")
	if scene_path != "":
		var scene : PackedScene = load(scene_path)
		var previous = get_node(current_menu)
		emit_signal("loaded")
		var another_menu : Control = scene.instance()
		get_node(current_menu).queue_free()
		another_menu.set_owner(self)
		if !another_menu.initial:
			another_menu.previous_path = get_node(current_menu).main_scene_path
		another_menu.main_scene_path = scene_path
		get_node("CurrentMenu").add_child(another_menu)
		current_menu = get_path_to(another_menu)
		emit_signal("changed")
		another_menu._update_owner(self)
	transition.play("Out")

func back_to_title_screen():
	change_scene("res://scenes/title-screen.tscn")

func change_scene(path: String):
	var fade = $Filter/Fade
	var transition = $Top/Transition
	var music_tween = $MusicProcess/Tween
	var music = $MusicProcess
	transition.play("In")
	yield(transition,"animation_finished")
	fade.play("Fadeout")
	yield(fade, "animation_finished")
	music_tween.interpolate_property(music, "volume_db", music.volume_db, -27, 1.0)
	music_tween.start()
	yield(music_tween, "tween_completed")
	get_tree().change_scene(path)

func update():
	$ColorRect.hue = get_node(current_menu).hue_value
