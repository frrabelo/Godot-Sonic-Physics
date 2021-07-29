extends Node
class_name AudioPlayer

export var audios = {}
var instantied_players = {}

func play(audio_name : String, from : float = 0.0) -> void:
	if audios.has(audio_name):
		#print(audios[audio_name], audio_name)
		var stream : AudioStreamPlayer
		if !instantied_players.has(audio_name):
			stream = AudioStreamPlayer.new()
			stream.set_stream(audios[audio_name])
			stream.connect('finished', self, 'delete_stream', [audio_name])
			stream.set_bus('SFX')
			add_child(stream)
			instantied_players[audio_name] = stream
		else:
			stream = instantied_players[audio_name]
		stream.play(from)

func stop(audio_name : String):
	instantied_players[audio_name].stop()
	delete_stream(audio_name)

func get_player(audio_name : String) -> AudioStream:
	assert (audios.has(audio_name), "Audio name not exist")
	return audios[audio_name]

func delete_stream(audio_name:String):
	if instantied_players.has(audio_name):
		var stream = instantied_players[audio_name]
		instantied_players.erase(audio_name)
		if stream.is_inside_tree():
			stream.queue_free()
