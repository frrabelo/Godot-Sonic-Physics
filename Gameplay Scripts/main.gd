extends Node

var count:float = 0;
var seconds:float = 0;
var milliseconds:float;
var minutes:float;
var ring:int = 0 setget setRing, getRings;
var time:String;
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func setRing(value:int):
	ring = value;
	if ($PlayerCamera != null):
		$PlayerCamera/HUD/RingCounter.text = String(ring);

func getRings():
	return ring;

func _process(delta):
	count += delta;
	seconds = fmod(count, 60);
	minutes = floor(count / 60);
	milliseconds = (count *1000);
	var strMs = "%d" % milliseconds
	var twoDigits = "";
	if strMs.length() > 3:
		twoDigits = strMs[2] + strMs[3]
	time = "%s%d'%s%d''%s" % ["0" if minutes < 10 else "", minutes, "0" if seconds < 10 else "", seconds, twoDigits]
	if $PlayerCamera != null:
		$PlayerCamera/HUD/TimeCounter.text = time;
	if Input.is_action_just_pressed("ui_full_screen"):
		OS.window_fullscreen = !OS.window_fullscreen
