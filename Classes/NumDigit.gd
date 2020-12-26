tool
extends Node2D
class_name NumCounter


export var number = 0 setget setNum, getNum;

func setNum(num:int):
	number = num % 10;
	refresh();

func getNum():
	return number;

func refresh():
	$SpriteCount.frame = number;

func _enter_tree():
	refresh();

func _ready():
	refresh();

func _script_changed():
	refresh();
