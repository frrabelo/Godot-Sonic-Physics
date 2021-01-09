extends Node

var count:float = 0;
var seconds:float = 0;
var milliseconds:float;
var minutes:float;
var ring:int = 100 setget setRing, getRings;
var time:String;
func _ready():
	pass
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func setRing(value:int):
	ring = value;
	if ($PlayerCamera != null):
		$PlayerCamera/CameraScroll/HUD/RingCounter.text = String(ring);

func getRings():
	return ring;

func _process(delta):
	count += delta;
	seconds = int(count) % 60;
	minutes = floor(count / 60);
	milliseconds = floor((fmod(count, 60) - seconds) * 100);
	time = "%s%d'%s%d''%s%d" % ["0" if minutes < 10 else "", minutes, "0" if seconds < 10 else "", seconds, "0" if milliseconds < 10 else "", milliseconds]
	if $PlayerCamera != null:
		$PlayerCamera/CameraScroll/HUD/TimeCounter.text = time;
	if Input.is_action_just_pressed("ui_full_screen"):
		OS.window_fullscreen = !OS.window_fullscreen
