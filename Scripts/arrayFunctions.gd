extends Node

class_name arrayFunctions

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
