tool
extends Node2D
class_name BlockGen
export var size:Vector2 setget setSize, getSize;
export var objectSelect:PackedScene setget setScene, getScene;
var object:PackedScene;
export var columns:int = 1 setget setBlockCol, getBlockCol;
export var rows:int = 1 setget setBlockRow, getBlockRow;
export(bool) var clear setget clear, cleared;

func erase():
	var children = get_children();
	for i in children:
		remove_child(i);

func clear(value:bool = false):
	columns = 0;
	rows = 0;
	var children = get_children();
	for i in children:
		remove_child(i);

func cleared():
	return false;

func setBlockCol(valueCol:int):
	if valueCol < 1000 && valueCol >= 0 :
		columns = valueCol;
		drawAll();

func setBlockRow(value:int):
	if value < 1000 && value >= 0 :
		rows = value;
		drawAll();

func drawAll():
	erase();
	if object != null:
		for y in range(0, rows):
			for x in range(0, columns):
				var objInstance:Node2D = object.instance(PackedScene.GEN_EDIT_STATE_MAIN)
				add_child(objInstance);
				objInstance.position = Vector2(x, y) * size;

func getBlockRow():
	return rows;

func getBlockCol():
	return columns

func setScene(value:PackedScene):
	object = value;
	drawAll();

func getScene():
	return object;

func setSize(value:Vector2):
	size = value;
	drawAll();

func getSize():
	return size

func _on_BlockGen_script_changed():
	drawAll();
