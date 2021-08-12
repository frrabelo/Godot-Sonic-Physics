extends AudioPlayer

func _enter_tree() -> void:
	audios = {
		'Destroy': preload("res://game-assets/audio/sfx/destroy.wav")
	}
