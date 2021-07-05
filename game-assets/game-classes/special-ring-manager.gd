extends Node2D
tool

onready var sprite = get_node('SpecialRingSprite')
onready var viewport_model = sprite.get_node('3DVisual')
onready var model = viewport_model.get_node('EmeraldRing')

func _ready() -> void:
	var texture = viewport_model.get_texture()
	if texture:
		sprite.texture = texture

func _on_OpenTrigger_screen_entered() -> void:
	if !Engine.editor_hint:
		model.spawn();


func _on_OpenTrigger_screen_exited() -> void:
	if !Engine.editor_hint:
		model.unSpawn();
