extends Node

class_name NeuralNet
var array = []
var NetSize

var lnPLNC
var O_array_buffer
var M_array_buffer
var B_buffer
var O_array_bufferA = [] # an array of all O_array_buffers
var M_array_bufferA = [] # an array of all B_array_buffers
var B_bufferA = []       # an array of all B_buffers

var oR = 1.0
var mR = 0.1
var bR = 0.1

func initialize(iNetSize):
	NetSize = iNetSize
	for l in range(0, NetSize.size()): # for layer in range(0, layerAmount)
		array.append([])
		for n in range(0, NetSize[l]): # for node in range(0, nodeAmount)
			if l == 0:
				array[l].append(NeuralInput.new())
				array[l][array[l].size()-1].set_name(String(["Input Node",n]))
			elif l < NetSize.size()-1:
				array[l].append(NeuralNode.new())
				array[l][array[l].size()-1].set_name(String(["Node",n]))
				array[l][n].initialize(array[l-1].size())
			elif l == NetSize.size()-1:
				array[l].append(NeuralNode.new())
				array[l][array[l].size()-1].set_name(String(["Output Node",n]))
				array[l][n].initialize(array[l-1].size())

func generateRandomStepArray(i_lnPLNC, i_array_buffer, is_offset):
	i_array_buffer = []
	if is_offset:
		for i in range(0, i_lnPLNC):
			i_array_buffer.append(rand_range(-oR,oR))
		return i_array_buffer
	else:
		for i in range(0, i_lnPLNC):
			i_array_buffer.append(rand_range(-mR,mR))
		return i_array_buffer

func pairArraySubtract(array1,array2):
	var array_buffer = []
	
	if array1.size() != array2.size():
		push_error("array1 and array2 not of same size")
	else:
		for n in range(0, array1.size()):
			array_buffer.append( array1[n] - array2[n] )
		return array_buffer

func pairArrayAdd(array1,array2):
	var array_buffer = []
	if array1.size() != array2.size():
		push_error("array1 and array2 not of same size")
	else:
		for n in range(0, array1.size()):
			array_buffer.append( array1[n] + array2[n] )
		return array_buffer

func NetVarArrayRandomStep():
	O_array_bufferA = []
	M_array_bufferA = []
	B_bufferA = []
	for l in range(0, NetSize.size()): # for layer in range(0, layerAmount)
		O_array_bufferA.append([])
		M_array_bufferA.append([])
		B_bufferA.append([])
		for n in range(0, NetSize[l]): # for node in range(0, nodeAmount)
			if l == 0:
				pass
			elif l < NetSize.size()-1:
				lnPLNC = array[l][n].PreviousLayerNodeCount
				
				O_array_bufferA[l].append([])
				M_array_bufferA[l].append([])
				B_bufferA[l].append([])
				
				O_array_buffer = generateRandomStepArray(lnPLNC, O_array_buffer, true)
				M_array_buffer = generateRandomStepArray(lnPLNC, M_array_buffer, false)
				B_buffer = rand_range(-bR,bR)
				
				O_array_bufferA[l][n].append(O_array_buffer)
				M_array_bufferA[l][n].append(M_array_buffer)
				B_bufferA[l][n].append(B_buffer)
				
				array[l][n].offset = pairArrayAdd(array[l][n].offset,O_array_buffer)
				array[l][n].multiplier = pairArrayAdd(array[l][n].multiplier,M_array_buffer)
				array[l][n].bias = array[l][n].bias + B_buffer

func ReverseLastNetVarArrayRandomStep():
	for l in range(0, NetSize.size()): # for layer in range(0, layerAmount)
		for n in range(0, NetSize[l]): # for node in range(0, nodeAmount)
			if l == 0:
				pass
			elif l < NetSize.size()-1:
				O_array_buffer = O_array_bufferA[l][n][0]
				M_array_buffer = M_array_bufferA[l][n][0]
				array[l][n].offset = pairArraySubtract(array[l][n].offset,O_array_buffer)
				array[l][n].multiplier = pairArraySubtract(array[l][n].multiplier,M_array_buffer)
				B_buffer = B_bufferA[l][n][0]
				array[l][n].bias = array[l][n].bias - B_buffer

func processNet():
	var inputs = []
	var output_buffer = []
	for l in range(0, array.size()): # for layer in range(0, layerAmount)
		output_buffer = []
		for n in range(0, array[l].size()): # for node in range(0, nodeAmount)
			if l == 0:
				inputs.append(array[l][n].Value)
			else:
				output_buffer.append(array[l][n].process(inputs))
		if l > 0:
			inputs = output_buffer
	return output_buffer
