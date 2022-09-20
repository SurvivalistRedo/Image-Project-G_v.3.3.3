extends Node

class_name NeuralNode
var PreviousLayerNodeCount
var offset = []
var multiplier = []
var bias = 0

func initialize(iPreviousLayerNodeCount):
	PreviousLayerNodeCount = iPreviousLayerNodeCount
	for _n in range(1,PreviousLayerNodeCount+1):
		randomize()
		offset.append(0.0)
		multiplier.append(0.0)
		bias = 0.0

func activation(x):
	return max(x,0.0)

func process(input):
	var sum = 0
	for i in range(0,input.size()):
		sum += ( input[i] + offset[i] ) * multiplier[i]
	return activation(sum+bias)
