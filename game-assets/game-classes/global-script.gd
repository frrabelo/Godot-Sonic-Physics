extends Node

enum Characters {
	SONIC = 0, TAILS = 1, KNUCKLES = 2, MIGHTY = 3, RAY = 4, SONIC_TAILS = 5
}

var loaded_data: Array = []

class PlayerInfo:
	var character_id : int
	
	func _init(char_id : int) -> void:
		character_id = char_id

var players : = [
	PlayerInfo.new(Characters.SONIC)
]

func erase():
	players.clear()
