extends Resource
class_name ButtonOptions

enum Type{
	SWITCH, MULTIPLE
}

export(Type) var test = Type.SWITCH

func _ready():
	pass
