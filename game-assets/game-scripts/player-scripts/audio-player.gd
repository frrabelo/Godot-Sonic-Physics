extends Node
class_name AudioPlayer

var audios = {}

func _enter_tree() -> void:
	for i in get_children():
		audios[(i).name] = i

func play(audio_name : String, from : float = 0.0) -> void:
	if audios.has(audio_name):
		#print(audios[audio_name], audio_name)
		audios[audio_name].play(from)

func stop(audio_name : String):
	audios[audio_name].stop()

func get_player(audio_name : String) -> AudioStreamPlayer:
	assert (audios.has(audio_name), "Audio name not exist")
	return audios[audio_name]
