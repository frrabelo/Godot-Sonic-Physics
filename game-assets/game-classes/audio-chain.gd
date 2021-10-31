extends Node
class_name MusicProcess

export var preSong:AudioStream;
export var song:AudioStream;
export var autoplay:bool = false
export var loop:bool = false

onready var pre_player = AudioStreamPlayer.new()
onready var song_player = AudioStreamPlayer.new()

func _ready():
	add_child(pre_player)
	add_child(song_player)
	pre_player.connect("finished", self, "pre_song_finished")
	song_player.connect("finished", self, "song_finished")
	var to_play = pre_player
	if preSong:
		pre_player.stream = preSong
		preSong.set("loop", false);
	if song:
		song_player.stream = song
		song.set("loop", loop);
		if !preSong:
			to_play = song_player
	else:
		return
	if autoplay:
		to_play.play()

func pre_song_finished():
	song_player.play()
	pre_player.queue_free()

func song_finished():
	pass
