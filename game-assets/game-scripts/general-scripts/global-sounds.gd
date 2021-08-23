extends AudioPlayer

func _enter_tree() -> void:
	audios = {
		'Destroy': preload("res://game-assets/audio/sfx/destroy.wav"),
		'CliffBreaking': preload('res://game-assets/audio/sfx/cliff-breaking.wav'),
		'WallBreak': preload('res://game-assets/audio/sfx/cliff-break.wav')
	}
