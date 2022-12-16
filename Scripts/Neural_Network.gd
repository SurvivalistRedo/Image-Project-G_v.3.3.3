extends Node

class_name Neural_Network

var servingNimage = false

var nodesPerLayer = [] # Amount of Nodes per each layer, with quantity of layers being assumed from nodesPerLayer.size()
var networkArray = []  # Array of Network
var inputArray = []    # Array of Nets Inputs

var NAS_nPS_H = []  # Network Array Step of node Parameter Steps HISTORY
var NAS_nMAS = [] # Network Array Step of node Multiplier Array Steps
var NAS_nBS = []  # Network Array Step of node Bias Steps
var nMASB = []    # node Multiplier Array Step Buffer
var nBSB = 0.0    # node Bias Step Buffer

const e = 2.718

var activation_function = -1
enum {Sigmoid,GeLu,ReLu,Sin}

func initialize(inputArraySize,iNodesPerLayer,mOffset = 0.0):
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
				#multiplier_array_buffer.append(rand_range(-Global.multRange/sqrt(node+1.0),Global.multRange/sqrt(node+1.0)))
				multiplier_array_buffer.append(mOffset+rand_range(-Global.multRange,Global.multRange))
				bias_float_buffer = rand_range(-Global.biasRange,Global.biasRange)
			networkArray[layer].append([multiplier_array_buffer,bias_float_buffer])
	#printNetwork()
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
	return 1 - (r/(1+pow(e,x)))
func deSigmoid(x,r):
	return r*pow(e,x) / pow((1+pow(e,x)),2.0)
func f(x):
	return (x+1.0)/2.0
func GeLu(x,a = -1):
	return (x)/(1.0+(pow(e,(a*x))))
func deGeLu(x,a = -1):
	var numerator = (a * x * pow(e,a*x)) - (1) - (pow(e,a*x))
	var denominator = pow(1 + pow(e,a*x),2)
	return -1 * (numerator/denominator)
func ReLu(x):
	return max(0.0,x)
func deReLu(x):
	if x >= 0:
		return 1
	else:
		return 0

func processNodeOutput(node,inputs):
	var sum = 0
	for pn in range(0,inputs.size()):
		sum += inputs[pn] * node[0][pn]
	var weighted_output = sum + node[1]
	match(activation_function):
		0:
			return Sigmoid(weighted_output,2.0)
		1:
			return GeLu(weighted_output)
		2:
			return ReLu(weighted_output)
		3:
			return sin(weighted_output)
		_:
			return weighted_output
func processOutputs(layerToInsert = 0):
	# f(x) = x * node[multiplier]
	# g(i) = sum of f(previousLayersOutputs[i]) + node[bias]
	# node output = activationFuncion(g(i)) i = range(n = 0, n < previousLayersNodes.size(), n++)
	# repeat this process from start to end of network
	# return final layers outputs
	var previousLayerOutputs = []
	var currentLayerOutputs = []
	var layerOutputs = []
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
		layerOutputs.append(currentLayerOutputs.duplicate(true))
	
	if servingNimage:
		if false:
			var color_buffer = Color.from_hsv(f(currentLayerOutputs.duplicate(true)[0]),f(currentLayerOutputs.duplicate(true)[1]),f(currentLayerOutputs.duplicate(true)[2]))
			return [color_buffer.r,color_buffer.g,color_buffer.b]
		else:
			var color_buffer = Color(f(currentLayerOutputs.duplicate(true)[0]),f(currentLayerOutputs.duplicate(true)[1]),f(currentLayerOutputs.duplicate(true)[2]))
			return [color_buffer.r,color_buffer.g,color_buffer.b]
	else:
		return layerOutputs
func pairArrayAbsoluteDifference(array1,array2):
	var array_buffer = []
	if array1.size() != array2.size():
		push_error("array1.size() != array2.size()")
		print("pairArrayAbsoluteDifference(",array1,",",array2,")")
		get_tree().quit()
	else:
		for n in range(0, array1.size()):
			if (typeof(array1[n]) == TYPE_ARRAY) && (typeof(array2[n]) == TYPE_ARRAY):
				array_buffer.append(pairArrayAbsoluteDifference(array1[n],array2[n]).duplicate(true))
			elif (typeof(array1[n]) != TYPE_ARRAY) && (typeof(array2[n]) != TYPE_ARRAY):
				array_buffer.append( abs( array1[n] - array2[n] ) )
			else:
				push_error("bruh idk bug in Neural_Network.pairArrayAbsoluteDifference()")
				get_tree().quit()
		return array_buffer.duplicate(true)
func pairArraySubtract(array1,array2):
	var array_buffer = []
	if array1.size() != array2.size():
		push_error("array1.size() != array2.size()")
		print("pairArraySubtract(",array1,",",array2,")")
		get_tree().quit()
	else:
		for n in range(0, array1.size()):
			if (typeof(array1[n]) == TYPE_ARRAY) && (typeof(array2[n]) == TYPE_ARRAY):
				array_buffer.append(pairArraySubtract(array1[n],array2[n]).duplicate(true))
			elif (typeof(array1[n]) != TYPE_ARRAY) && (typeof(array2[n]) != TYPE_ARRAY):
				array_buffer.append( array1[n] - array2[n] )
			else:
				push_error("bruh idk bug in Neural_Network.pairArraySubtract()")
				get_tree().quit()
		return array_buffer.duplicate(true)
func pairArrayAdd(array1,array2):
	var array_buffer = []
	if array1.size() != array2.size():
		push_error("array1.size() != array2.size()")
		print("pairArrayAdd(",array1,",",array2,")")
		get_tree().quit()
	else:
		for n in range(0,array1.size()):
			if (typeof(array1[n]) == TYPE_ARRAY) && (typeof(array2[n]) == TYPE_ARRAY):
				array_buffer.append(pairArrayAdd(array1[n],array2[n]).duplicate(true))
			elif (typeof(array1[n]) != TYPE_ARRAY) && (typeof(array2[n]) != TYPE_ARRAY):
				array_buffer.append( array1[n] + array2[n] )
			else:
				push_error("bruh idk bug in Neural_Network.pairArrayAdd()")
				get_tree().quit()
		return array_buffer.duplicate(true)
func multiplyArray(array,multiplier):
	var array_buffer = []
	for n in array.size():
		if typeof(array[n]) == TYPE_ARRAY:
			array_buffer.append(multiplyArray(array[n],multiplier).duplicate(true))
		elif typeof(array[n]) != TYPE_ARRAY:
			array_buffer.append( array[n] * multiplier )
		else:
			push_error("bruh idk bug in Neural_Network.multiplyArray()")
			get_tree().quit()
	return array_buffer.duplicate(true)
func divideArray(array,denominator):
	var array_buffer = []
	for n in array.size():
		if typeof(array[n]) == TYPE_ARRAY:
			array_buffer.append(divideArray(array[n],denominator).duplicate(true))
		elif typeof(array[n]) != TYPE_ARRAY:
			array_buffer.append( array[n] / denominator )
		else:
			push_error("bruh idk bug in Neural_Network.divideArray()")
			get_tree().quit()
	return array_buffer.duplicate(true)

func generateRandomStepArray(currentLayer,i_array_buffer,i_range):
	i_array_buffer = []
	if currentLayer == 0:
		for i in range(0,inputArray.size()):
			#i_array_buffer.append(rand_range(-i_range/sqrt(i+1.0),i_range/sqrt(i+1.0)))
			i_array_buffer.append(rand_range(-i_range,i_range))
	else:
		for i in range(0,nodesPerLayer[currentLayer-1]):
			#i_array_buffer.append(rand_range(-i_range/sqrt(i+1.0),i_range/sqrt(i+1.0)))
			i_array_buffer.append(rand_range(-i_range,i_range))
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
func NetAddParameterStep(parameterStep,i_steps = 1,record = false):
	if record:
		NAS_nPS_H.append(parameterStep.duplicate(true))
	for l in range(0,nodesPerLayer.size()): # for layer in range(0, layerAmount)
		for n in range(0,nodesPerLayer[l]): # for node in range(0, nodeAmount)
			var averagedGradientStep = divideArray(parameterStep[l][n][0].duplicate(true),i_steps)
			networkArray[l][n][0] = pairArrayAdd(networkArray[l][n][0],averagedGradientStep.duplicate(true))
			networkArray[l][n][1] = networkArray[l][n][1] + (parameterStep[l][n][1]/i_steps)
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

func gradientDescentSingleLayer(layer,targetOutput,learningRate):
	var outputs = processOutputs()
	
	var gradientStep = []
	for i in nodesPerLayer.size():
		gradientStep.append([])
		for j in nodesPerLayer[i]:
			gradientStep[i].append([])
			gradientStep[i][j].append([])
			if i == 0:
				for k in inputArray.size():
					gradientStep[i][j][0].append(0)
			else:
				for k in nodesPerLayer[i-1]:
					gradientStep[i][j][0].append(0)
			gradientStep[i][j].append(0)
	
	if targetOutput.size() == outputs[layer].size():
		for node in targetOutput.size():
			var dl_dno = (-2*targetOutput[node])+(2*outputs[layer][node]) # derivative of the loss in respect to the nodes output
			var da_dwo # derivative of the activated output with respect the the weighted output
			match(activation_function):
				0:
					da_dwo = deSigmoid(1,2.0)
				1:
					da_dwo = deGeLu(1)
				2:
					da_dwo = deReLu(1)
				_:
					da_dwo = cos(1)
			for weight in networkArray[layer][node][0].size():
				var dwo_dw = outputs[layer-1][weight] # derivative of the weighted output with respect to a weight (the activated output that the weight is assigned to)
				gradientStep[layer][node][0][weight] -= learningRate*(dwo_dw*da_dwo*dl_dno)
			var dwo_db # derivative of the weighted output with respect the bias
			gradientStep[layer][node][1] -= learningRate*(1*da_dwo*dl_dno)
		return gradientStep
	else:
		push_error("targetOutput.size() != outputs[layer].size()")
		get_tree().quit()














