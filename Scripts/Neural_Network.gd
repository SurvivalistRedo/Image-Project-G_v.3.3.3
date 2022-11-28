extends Node

class_name Neural_Network

var nodesPerLayer = [] # Amount of Nodes per each layer, with quantity of layers being assumed from nodesPerLayer.size()
var networkArray = []  # Array of Network
var inputArray = []    # Array of Nets Inputs

var NAS_nPS_H = []  # Network Array Step of node Parameter Steps HISTORY
var NAS_nMAS = [] # Network Array Step of node Multiplier Array Steps
var NAS_nBS = []  # Network Array Step of node Bias Steps
var nMASB = []    # node Multiplier Array Step Buffer
var nBSB = 0.0    # node Bias Step Buffer

func initialize(inputArraySize,iNodesPerLayer):
	# Creates Network
	nodesPerLayer = iNodesPerLayer
	for _n in range(0,inputArraySize):
		inputArray.append(0.0)
	var IfPL = [] # Inputs from Previous Layer
	var PLNQ = 0  # Previous Layer Node Quantity
	for layer in range(0,nodesPerLayer.size(),1):
		if layer == 0:
			PLNQ = inputArray.size()
		else:
			IfPL = []
			for node in range(0,nodesPerLayer[layer-1]):
				IfPL.append([])
			PLNQ = IfPL.size()
		networkArray.append([])
		for node in range(0,nodesPerLayer[layer]):
			var multiplier_array_buffer = []
			var bias_float_buffer = 0
			for c in range(0,PLNQ):
				multiplier_array_buffer.append(rand_range(-Global.multRange/sqrt(node+1.0),Global.multRange/sqrt(node+1.0)))
				bias_float_buffer = rand_range(-Global.biasRange,Global.biasRange)
			networkArray[layer].append([multiplier_array_buffer,bias_float_buffer])
	printNetwork()
	processOutputs()

func printNetwork():
	print()
	for input in range(0,inputArray.size()):
		print("Input",input,": ",inputArray[input])
	for layer in range(0,nodesPerLayer.size(),1):
		print()
		print("Layer ",layer,"; ")
		for node in range(0,nodesPerLayer[layer]):
			print("Node",node,": ",networkArray[layer][node])
	print()
func printNAS_nPS_H():
	print()
	for i in range(0,NAS_nPS_H.size()):
		print("Iteration ",i,"; ")
		for layer in range(0,NAS_nPS_H[i].size()):
			print()
			print("Layer ",layer,"; ")
			for node in range(0,NAS_nPS_H[i][layer].size()):
				print("Node",node,": ",NAS_nPS_H[i][layer][node])
	print()

func f1(x,y):
	return 1.0 / (0.1 + (y * x))
func f2(x):
	if x < 0.0:
		return f1(x,-1.0)
	if x == 0.0:
		return 10.0
	if x > 0.0:
		return f1(x,1.0)
func f3(x):
	return max(f2(x)-f2(PI),0)
func f4(x):
	return sin(x) * f3(x)
func f5(x):
	return f4(0.400173*x) * (1 / f4(0.400173))
func Sigmoid(x,r):
	return 1 - (r/(1+pow(2.718,x)))
func deSigmoid(x,r):
	return r*pow(2.718,x) / pow((1+pow(2.718,x)),2.0)
func f(x):
	return (x+1.0)/2.0
func GeLu(x):
	return (x)/(1.0+(pow(2.718,(-1.702*x))))
func ReLu(x):
	return max(0.0,x)

func processNodeOutput(node,inputs):
	var sum = 0
	for pn in range(0,inputs.size()):
		sum += inputs[pn] * node[0][pn]
	return sin(sum+node[1])
func processOutputs():
	# f(x) = x * node[multiplier]
	# g(i) = sum of f(previousLayersOutputs[i]) + node[bias]
	# node output = activationFuncion(g(i)) i = range(n = 0, n < previousLayersNodes.size(), n++)
	# repeat this process from start to end of network
	# return final layers outputs
	var previousLayerOutputs = []
	var currentLayerOutputs = []
	for layer in range(0,nodesPerLayer.size(),1):
		currentLayerOutputs = []
		if layer == 0:
			for input in range(0,inputArray.size()):
				previousLayerOutputs.append(inputArray[input])
			for node in range(0,nodesPerLayer[layer]):
				currentLayerOutputs.append(processNodeOutput(networkArray[layer][node].duplicate(true),previousLayerOutputs.duplicate(true)))
			previousLayerOutputs = currentLayerOutputs.duplicate(true)
		else:
			for node in range(0,nodesPerLayer[layer]):
				currentLayerOutputs.append(processNodeOutput(networkArray[layer][node].duplicate(true),previousLayerOutputs.duplicate(true)))
			previousLayerOutputs = currentLayerOutputs.duplicate(true)
	
	var color_buffer = Color.from_hsv(f(currentLayerOutputs.duplicate(true)[0]),f(currentLayerOutputs.duplicate(true)[1]),f(currentLayerOutputs.duplicate(true)[2]))
	return [color_buffer.r,color_buffer.g,color_buffer.b]
func pairArraySubtract(array1,array2):
	var array_buffer = []
	if array1.size() != array2.size():
		push_error("array1 and array2 not of same size!")
		print("pairArraySubtract(",array1,",",array2,")")
		get_tree().quit()
	else:
		for n in range(0, array1.size()):
			array_buffer.append( array1[n] - array2[n] )
		return array_buffer.duplicate(true)
func pairArrayAdd(array1,array2):
	var array_buffer = []
	if array1.size() != array2.size():
		push_error("array1 and array2 not of same size!")
		print("pairArrayAdd(",array1,",",array2,")")
		get_tree().quit()
	else:
		for n in range(0,array1.size()):
			array_buffer.append( array1[n] + array2[n] )
		return array_buffer.duplicate(true)

func generateRandomStepArray(currentLayer,i_array_buffer,i_range):
	i_array_buffer = []
	if currentLayer == 0:
		for i in range(0,inputArray.size()):
			i_array_buffer.append(rand_range(-i_range/sqrt(i+1.0),i_range/sqrt(i+1.0)))
	else:
		for i in range(0,nodesPerLayer[currentLayer-1]):
			i_array_buffer.append(rand_range(-i_range/sqrt(i+1.0),i_range/sqrt(i+1.0)))
	return i_array_buffer.duplicate(true)

func NetParametersRandomStep():
	NAS_nPS_H.append([])
	NAS_nMAS = [] # Network Array Step of node Multiplier Array Steps
	NAS_nBS = [] # Network Array Step of node Bias Steps
	for l in range(0,nodesPerLayer.size()): # for layer in range(0, layerAmount)
		NAS_nPS_H[NAS_nPS_H.size()-1].append([])
		NAS_nMAS.append([])
		NAS_nBS.append([])
		for n in range(0,nodesPerLayer[l]): # for node in range(0, nodeAmount)
			NAS_nPS_H[NAS_nPS_H.size()-1][l].append([])
			NAS_nMAS[l].append([])
			NAS_nBS[l].append([])
			
			nMASB = generateRandomStepArray(l,nMASB.duplicate(true),Global.multRange)
			nBSB = rand_range(-Global.biasRange,Global.biasRange)
			NAS_nPS_H[NAS_nPS_H.size()-1][l][n] = [nMASB.duplicate(true),nBSB]
			
			NAS_nMAS[l][n].append(nMASB.duplicate(true))
			NAS_nBS[l][n].append(nBSB)
			
			networkArray[l][n][0] = pairArrayAdd(networkArray[l][n][0],nMASB.duplicate(true))
			networkArray[l][n][1] = networkArray[l][n][1] + nBSB
func signFlipNetParametersStep():
	pass
func ReverseLastNetParametersRandomStep():
	if NAS_nPS_H.size()-1 < 0:
		push_error("NAS_nPS_H.size()-1 < 0")
		return
	for l in range(0,nodesPerLayer.size()): # for layer in range(0, layerAmount)
		for n in range(0,nodesPerLayer[l]): # for node in range(0, nodeAmount)
			nMASB = NAS_nPS_H[NAS_nPS_H.size()-1][l][n][0].duplicate(true)
			nBSB = NAS_nPS_H[NAS_nPS_H.size()-1][l][n][1]
			networkArray[l][n][0] = pairArraySubtract(networkArray[l][n][0],nMASB)
			networkArray[l][n][1] = networkArray[l][n][1] - nBSB
	NAS_nPS_H.remove(NAS_nPS_H.size()-1)
