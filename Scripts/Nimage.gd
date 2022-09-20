extends Sprite

var NeuralNet

var img
var record = 0
var eRecord = 0

var resolution = 100
var graph_size = 5

var Iterations = 1000
var currentIteration = 1000
var x = false

var s

var mR = 1.5
var bR = 1.5

var printProgress = true

func _ready():
	get_tree().get_root().set_transparent_background(true)
	randomize()
	NeuralNet = NeuralNetwork.new()
	NeuralNet.initialize(2,[50,12,6,3])
	#NeuralNet.NetParametersRandomStep()
	#processNeuralImage()

func _process(delta):
	selector()
	
	if Input.is_action_just_pressed('ui_focus_next'):
		processNeuralImage(false)
	
	if Input.is_action_pressed("X"):
		x = false
	
	if x and currentIteration < Iterations:
		if currentIteration < Iterations:
			NeuralNet.NetParametersRandomStep()
			processNeuralImage(true)
			print(currentIteration,"/",Iterations)
			currentIteration += 1
		else:
			x = false
			currentIteration = 0
			processNeuralImage(false)
			print(currentIteration,"/",Iterations)
	else:
		if Input.is_action_just_pressed('ui_up'):
			x = true
			currentIteration = 0
	
	if Input.is_action_just_pressed('ui_accept'):
		resolution = 1000
		processNeuralImage(false)
	
	if Input.is_action_pressed('ui_page_up'):
		resolution += 10
		print("Resolution = ",resolution)
	if Input.is_action_pressed('ui_page_down'):
		resolution -= 10
		print("Resolution = ",resolution)
	
	if Input.is_action_just_pressed('ui_home'):
		printProgress = true
	if Input.is_action_just_pressed('ui_end'):
		printProgress = false
	
	if Input.is_action_just_pressed('ui_left'):
		NeuralNet.ReverseLastNetParametersRandomStep()
		processNeuralImage(false)
	if Input.is_action_just_pressed('ui_right'):
		NeuralNet.NetParametersRandomStep()
		processNeuralImage(false)
	
	if Input.is_action_just_pressed("P"):
		NeuralNet.printNetwork()

func colorSum(rgb):
	return rgb.r+rgb.g+rgb.b

func selector():
	if Input.is_action_pressed("1"):
		s = 1
	if Input.is_action_pressed("2"):
		s = 2
	if Input.is_action_pressed("3"):
		s = 3
	if Input.is_action_pressed("4"):
		s = 4
	match(s):
		1:
			pass
		2:
			if Input.is_action_pressed('up'):
				mR += 0.01
				print([mR,bR,Iterations],currentIteration)
			if Input.is_action_pressed('down'):
				mR -= 0.01
				print([mR,bR,Iterations],currentIteration)
		3:
			if Input.is_action_pressed('up'):
				bR += 0.01
				print([mR,bR,Iterations],currentIteration)
			if Input.is_action_pressed('down'):
				bR -= 0.01
				print([mR,bR,Iterations],currentIteration)
		4:
			if Input.is_action_pressed('up'):
				Iterations += 5.0
				currentIteration += 5.0
				print([mR,bR,Iterations],currentIteration)
			if Input.is_action_pressed('down'):
				Iterations -= 5.0
				print([mR,bR,Iterations],currentIteration)
		_:
			pass
	NeuralNet.multiplier_range = mR
	NeuralNet.bias_range = bR

func calculateContrast(reference):
	var sum = 0
	var imgBuffer = Image.new()
	imgBuffer.create(reference.get_width(),reference.get_height(),false,Image.FORMAT_RGB8)
	imgBuffer.copy_from(reference)
	imgBuffer.lock()
	for y in range(0,reference.get_height()):
		#if round(float(y+1.0)/reference.get_height()*1000.0)/10.0 == round(round(float(y+1.0)/reference.get_height()*1000.0)/10.0):
		#	print(round(float(y+1.0)/reference.get_height()*1000.0)/10.0,".0","%")
		#else:
		#	print(round(float(y+1.0)/reference.get_height()*1000.0)/10.0,"%")
		for x in range(0,reference.get_width()):
			for j in [-1,0,1]:
				if (y+j >= 0) && (y+j < reference.get_height()):
					for i in [-1,0,1]:
						if (x+i >= 0) && (x+i < reference.get_width()):
							sum += abs(colorSum(imgBuffer.get_pixel(x,y))-colorSum(imgBuffer.get_pixel(x+i,y+j)))
	sum = sum / ( reference.get_width() * reference.get_height() )
	if sum > record:
		record = sum
	return [sum,record]

func calculateError(reference, examinee):
	var width = examinee.get_width()
	var height = examinee.get_height()
	
	reference.unlock()
	reference.resize(width,height,4)
	reference.lock()
	
	var error = 0
	for x in range(0,width):
		for y in range(0,height):
			error += abs( colorSum(reference.get_pixel(x,y)) - colorSum(examinee.get_pixel(x,y)) )
	error = error/pow(resolution,2.0)
	if error < eRecord or eRecord == 0:
		eRecord = error
	return [error,eRecord]

func findMinMax(array):
	var Max = null
	var Min = null
	for n in range(0,array.size()):
		if Max == null:
			Max = array[n]
		else:
			if array[n] > Max:
				Max = array[n]
		if Min == null:
			Min = array[n]
		else:
			if array[n] < Min:
				Min = array[n]
	return [Min,Max]

func normalize(data):
	var array_buffer = []
	var MinMax = findMinMax(data)
	if (MinMax[0] - MinMax[1]) == 0:
		push_error("(MinMax[0] - MinMax[1]) == 0")
		return data.duplicate(true)
	for n in range(0,data.size()):
		array_buffer.append(255.0*((data[n]-MinMax[0])/(MinMax[1]-MinMax[0])))
	return array_buffer.duplicate(true)

func activation(data):
	var array_buffer = []
	for n in range(0,data.size()):
		array_buffer.append(min(max(data[n],0.0),255.0))
	return array_buffer.duplicate(true)

func processNeuralImage(reverseIfBad):
	var NeuralOutputMatrix = []
	
	for x in range(0,resolution):
		NeuralNet.inputArray[0] = (x-(resolution/2.0))*(graph_size/(resolution/2.0))
		if printProgress:
			print(x+1, "/", resolution)
		for y in range(0,resolution):
			NeuralNet.inputArray[1] = (y-(resolution/2.0))*(graph_size/(resolution/2.0))
			var outputs = NeuralNet.processOutputs()
			for i in range(0,outputs.size()):
				NeuralOutputMatrix.append(outputs[i])
	
	var normalizedNeuralOutputMatrix = normalize(NeuralOutputMatrix)
	var aOutputMatrix = activation(NeuralOutputMatrix)
	
	img = Image.new()
	img.create_from_data(resolution, resolution, false, Image.FORMAT_RGB8, PoolByteArray(aOutputMatrix))
	img.lock()
	img.save_png('res://aaa.png')
	
	var rad = Image.new()
	rad.create(600,600,false,Image.FORMAT_RGB8)
	rad.lock()
	rad = load('res://Radiation_warning_symbol.png')
	
	#var texture = ImageTexture.new()
	#texture.load('res://Radiation_warning_symbol.png')
	
	var sum_record = calculateContrast(img)
	print(sum_record)
	
	if reverseIfBad:
		if sum_record[0] == sum_record[1]:
			pass
		else:
			NeuralNet.ReverseLastNetParametersRandomStep()
	
	
	
	img.unlock()
	var txt = ImageTexture.new()
	img.resize(1000,1000,Image.INTERPOLATE_NEAREST)
	txt.create_from_image(img)
	texture = txt
