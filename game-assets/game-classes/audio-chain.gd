extends AudioStreamPlayer


export var preSong:AudioStream;
export var song:AudioStream;
export var postSong:AudioStream;

func _ready():
	if preSong != null:
		stream = preSong
		preSong.set("loop", false);
	else:
		if song != null:
			stream = song
			preSong.set("loop", true);
		else:
			return
	if autoplay:
		play();

func play(from:float=0.0) -> void:
	.play(from);

func _on_StageMusic_finished():
	match stream:
		preSong: 
			stream = song 
		song:
			if postSong != null:
				stream = postSong
		postSong:
			stream = song
	.play();
	pass
