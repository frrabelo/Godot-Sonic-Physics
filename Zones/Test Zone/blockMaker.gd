tool
extends Node2D
class_name BlockGen
export var size:Vector2 = Vector2(64, 64) setget setSize, getSize;
export var object:PackedScene setget setScene, getScene;
export var columns:int = 1 setget setBlockCol, getBlockCol;
export var rows:int = 1 setget setBlockRow, getBlockRow;

func erase():
	var children = get_children();
	for i in children:
		i.queue_free();

func setBlockCol(value:int):
	if value < 100 && value >= 0 && (value * rows) <= 100:
		columns = value;
		_makeAll();

func setBlockRow(value:int):
	if value < 100 && value >= 0 && (value * columns) <= 100:
		rows = value;
		_makeAll();

func _makeAll():
	erase();
	var parent:Node2D = Node2D.new();
	parent.position = Vector2.ZERO;
	.add_child(parent);
	if object != null:
		if columns > 0 && rows > 0:
			for y in range(0, rows):
				for x in range(0, columns):
					var objInstance:Node2D = object.instance()
					parent.add_child(objInstance);
					objInstance.position = Vector2(x, y) * size;

func getBlockRow():
	return rows;

func getBlockCol():
	return columns

func setScene(value:PackedScene):
	object = value;
	_makeAll();

func getScene():
	return object;

func setSize(value:Vector2):
	size = value;
	_makeAll();

func getSize():
	return size

func _on_BlockGen_script_changed():
	_makeAll()
