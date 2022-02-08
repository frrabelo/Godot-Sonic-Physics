extends OptionSelButton
tool

onready var all_player = $AllPlayer
export var text : String setget _set_text
onready var shade : Sprite = $ConfigName/HeadContainer/Shade
onready var head : Sprite = $ConfigName/HeadContainer/Head

func _ready():
	._ready()
	if !can_change_value:
		$ConfigName/HeadContainer/Arrows.visible = false

func _set_text(val : String) -> void:
	text = val
	update()

func _draw():
	if get_parent() is ButtonSelector:
		draw_string(get_parent().font, Vector2(10, 30), text, Color.white, -1)

func set_current_value(val : int) -> void:
	if option_values.size() > 0:
		current_value = val % (option_values.size())
	if current_value < 0:
		current_value = option_values.size() - 1
	if !Engine.editor_hint:
		if head:
			if option_values[current_value]["enabled"]:
				head.modulate = Color.white
			else:
				head.modulate = Color(0x11ffffff)
			head.frame = current_value
		if shade:
			shade.frame = current_value + ((shade.get_hframes() * shade.get_vframes()) / 2)
		if all_player:
			all_player.play("hover")

func on_accept():
	pass
