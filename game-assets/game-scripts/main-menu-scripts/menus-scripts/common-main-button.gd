extends MenuMainButton
tool


var text_node = get_node_or_null("./main/Label")
onready var label = $main/Label

func _enter_tree():
	if text_node:
		text_node.set_text(text)

func _ready():
	if label:
		label.set_text(text)
	if Engine.editor_hint || !scroll_container:
		set_process(false)

func _set_text(val : String) -> void:
	if val.length() <= 11:
		text = val
		if Engine.editor_hint:
			if text_node == null:
				text_node = get_node_or_null(@"./main/Label")
			else:
				text_node.text = text
		else:
			if label != null:
				label.set_text(text)
			else:
				label = get_node(@"main/Label")
