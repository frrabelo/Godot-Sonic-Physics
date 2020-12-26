tool
extends Node2D

func _draw():
	drawed();

func drawed():
	self.draw_circle(self.position, 5, Color.red)

