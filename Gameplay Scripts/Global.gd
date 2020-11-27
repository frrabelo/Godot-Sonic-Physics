extends Node

var controller:Dictionary = {
	"up": false,
	"left": false,
	"right": false,
	"down": false,
	"jump": false,
};

var controller_justpress:Dictionary = controller;

var controller_release:Dictionary = controller;

func _ready():
	set_process_input(true);
	pass

func _input(event):
	controller = {
		"up": Input.is_action_pressed("ui_up"),
		"left": Input.is_action_pressed("ui_left"),
		"right": Input.is_action_pressed("ui_right"),
		"down": Input.is_action_pressed("ui_down"),
		"jump": Input.is_action_pressed("ui_jump"),
	}
	controller_justpress = {
		"up": Input.is_action_just_pressed("ui_up"),
		"left": Input.is_action_just_pressed("ui_left"),
		"right": Input.is_action_just_pressed("ui_right"),
		"down": Input.is_action_just_pressed("ui_down"),
		"jump": Input.is_action_just_pressed("ui_jump"),
	}
	controller_release = {
		"up": Input.is_action_just_released("ui_up"),
		"left": Input.is_action_just_released("ui_left"),
		"right": Input.is_action_just_released("ui_right"),
		"down": Input.is_action_just_released("ui_down"),
		"jump": Input.is_action_just_released("ui_jump"),
	}
