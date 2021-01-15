extends Node2D

var time:String = "00000" setget setTime, getTime;

func setTime(value:String):
	if value.length() > 4:
		$Min/digit.number = int(value[0]);
		$Sec/Left.number = int(value[1]);
		$Sec/Right.number = int(value[2]);
		$MilS/Left.number = int(value[3]);
		$MilS/Right.number = int(value[4]);

func getTime():
	return time;
