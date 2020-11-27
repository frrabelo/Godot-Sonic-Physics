tool
extends SpriteFrames
class_name ImprovedSpriteFrames

export(Vector2) \
	var frame_offset;

func _ready():
	set_ofs();
	connect("frame_changed", self, "set_ofs")

func set_ofs():
	pass
