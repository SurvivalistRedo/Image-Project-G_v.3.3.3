extends Node2D

var NeuralNet = Neural_Network.new()

func _ready():
	get_node("ae1").margin_top = 0
	get_node("ae1").margin_bottom = 1000/3
	get_node("ae2").margin_top = 1000/3
	get_node("ae2").margin_bottom = (1000/3)*2
	get_node("ae3").margin_top = (1000/3)*2
	get_node("ae3").margin_bottom = 1000
	NeuralNet = Neural_Network.new()
	NeuralNet.activation_function = 2 # ReLu
	NeuralNet.initialize(3,[10,3,10,3])

func _process(delta):
	for i in 3:
		NeuralNet.inputArray[i] = rand_range(0,1)
	var netOutputs = NeuralNet.processOutputs()
	
	var netHSVestimate = []
	for i in 3:
		netHSVestimate.append(netOutputs[1][i])
	
	var netRGBestimate = []
	for i in 3:
		netRGBestimate.append(netOutputs[3][i])
	
	get_node("ae1").color = Color(NeuralNet.inputArray[0],NeuralNet.inputArray[1],NeuralNet.inputArray[2])
	get_node("ae2").color = Color.from_hsv(netHSVestimate[0],netHSVestimate[1],netHSVestimate[2])
	get_node("ae3").color = Color(netRGBestimate[0],netRGBestimate[1],netRGBestimate[2])
