extends Area2D

export var to_right:bool = true;

func _ready():
	pass

func _on_ChangeSpot_body_entered(body:Node):
	if body.is_class("Badnik"):
		var badnik:Badnik = body;
		if badnik.id_badnik == "motobug":
			badnik.to_right_change(to_right)
