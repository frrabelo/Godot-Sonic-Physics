extends AudioStreamPlayer
class_name MusicProcess
tool

export var pre_stream:AudioStream
export var main_stream:AudioStream
export var extension_autoplay: bool = false
var pre_song_played : bool

func _ready():
	stream = null
	if autoplay && (pre_stream || main_stream):
		play(0.0)

func play(val : float = 0.0) -> void:
	if !pre_stream && !main_stream:
		return
	assert(is_inside_tree(), "Playback can only happen when a node is inside the scene tree")
	if pre_stream:
		stream = pre_stream
		.play(val)
		yield(self,"finished")
		pre_song_played = true
	if main_stream:
		stream = main_stream
		.play(val)
