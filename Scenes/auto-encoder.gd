extends Node2D

func _ready():
	var NeuralNet = Neural_Network.new()
	NeuralNet.initialize(2,[10,3])

