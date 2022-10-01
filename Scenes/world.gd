extends Node2D

func _ready():
	get_node("FileDialog").popup(Rect2(50,50,900,900))
