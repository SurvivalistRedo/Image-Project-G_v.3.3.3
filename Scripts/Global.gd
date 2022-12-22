extends Node

var scenes = ["res://Image Generation/world.tscn","res://Auto Encoding/auto-encoder.tscn","res://Shaders/shadersad.tscn"]

var multRange = 0.01 # 1
var biasRange = 0.01 # 0.25
var step_size = 0.01 # 0.01

var scoreFunction = 1
var Iterations = 5000
var currentIteration = 5000

func _process(_delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://menu.tscn")
