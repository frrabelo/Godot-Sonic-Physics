extends Node

var count:float = 0;
var seconds:float = 0;
var milliseconds:float;
var minutes:float;
var rings:int = 100 setget set_ring;
var time:String;
func _ready():
	set_ring(rings)
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func set_ring(value:int):
	rings = value;
	if ($HUD != null):
		$HUD/Separate/STRCounters/Count/RingCounter.text = String(rings);


func get_global_mouse_position() -> Vector2:
	return Node2D.new().get_global_mouse_position()

func _process(delta):
	count += delta;
	seconds = int(count) % 60;
	minutes = floor(count / 60);
	milliseconds = floor((fmod(count, 60) - seconds) * 100);
	time = "%s%d'%s%d''%s%d" % ["0" if minutes < 10 else "", minutes, "0" if seconds < 10 else "", seconds, "0" if milliseconds < 10 else "", milliseconds]
	if $HUD != null:
		$HUD/Separate/STRCounters/Count/TimeCounter.text = time;
	if Input.is_action_just_pressed("ui_full_screen"):
		OS.window_fullscreen = !OS.window_fullscreen

func _delete_obj_signal (val : Node) -> void:
	val.queue_free()

func _prepare():
	pass
