extends Node2D

class_name AudioPlayer

var audios = {}

func _ready() -> void:
	for i in get_children():
		audios[(i as Node).name] = i

func play(audio_name : String, from : float = 0.0):
	#print(audios[audio_name], audio_name)
	audios[audio_name].play()

func stop(audio_name : String):
	audios[audio_name].stop()
