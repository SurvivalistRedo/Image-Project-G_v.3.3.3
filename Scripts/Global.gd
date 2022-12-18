extends Node

var scenes = ["res://Image Generation/world.tscn","res://Auto Encoding/auto-encoder.tscn","res://Shaders/shadersad.tscn"]

var multRange = 0.01 # 1
var biasRange = 0.01 # 0.25
var step_size = 0.01 # 0.01

var scoreFunction = 1
var Iterations = 1000
var currentIteration = 1000
