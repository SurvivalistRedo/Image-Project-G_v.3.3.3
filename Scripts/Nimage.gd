extends Sprite

var NeuralNet

var record = 0
var eRecord = 0

var resolution = 80
var graph_size = 5

var Iterations = 1000
var currentIteration = 1000
var x = false

var s

var mR = 1.0
var bR = 1.0

var printProgress = true

enum {contrast,referenceError}
enum {dontReverseIfWorse,doReverseIfWorse}
enum {returnImage,returnTexture}

var referencePath = "no input"

func _ready():
	get_tree().get_root().set_transparent_background(true)
	randomize()
	NeuralNet = NeuralNetwork.new()
	NeuralNet.initialize(2,[10,10,5,3])

func _process(delta):
	selector()
	
	if Input.is_action_just_pressed("ui_focus_next"):
		processNeuralImage(NeuralNet,resolution,contrast,dontReverseIfWorse)
	if Input.is_action_just_pressed("ui_accept"):
		resolution = 1000
		processNeuralImage(NeuralNet,resolution,contrast,dontReverseIfWorse)
	
	if Input.is_action_pressed("X"):
		x = false
	iterate()
	
	if Input.is_action_pressed("ui_page_up"):
		resolution += 10
		print("Resolution = ",resolution)
	if Input.is_action_pressed("ui_page_down"):
		resolution -= 10
		print("Resolution = ",resolution)
	
	if Input.is_action_just_pressed("ui_home"):
		printProgress = true
	if Input.is_action_just_pressed("ui_end"):
		printProgress = false
	
	if Input.is_action_just_pressed("ui_left"):
		NeuralNet.ReverseLastNetParametersRandomStep()
		processNeuralImage(NeuralNet,resolution,contrast,dontReverseIfWorse)
	if Input.is_action_just_pressed("ui_right"):
		NeuralNet.NetParametersRandomStep()
		processNeuralImage(NeuralNet,resolution,contrast,dontReverseIfWorse)
	
	if Input.is_action_just_pressed("P"):
		NeuralNet.printNetwork()

func iterate():
	if x and currentIteration < Iterations:
		if currentIteration < Iterations:
			NeuralNet.NetParametersRandomStep()
			processNeuralImage(NeuralNet,resolution,contrast,doReverseIfWorse)
			print(currentIteration+1,"/",Iterations)
			currentIteration += 1
		else:
			x = false
			currentIteration = 0
			processNeuralImage(NeuralNet,resolution,contrast,dontReverseIfWorse)
			print(currentIteration+1,"/",Iterations)
	else:
		if Input.is_action_just_pressed("ui_up"):
			x = true
			currentIteration = 0

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
			if Input.is_action_pressed("up"):
				mR += 0.01
				print([mR,bR,Iterations],currentIteration)
			if Input.is_action_pressed("down"):
				mR -= 0.01
				print([mR,bR,Iterations],currentIteration)
		3:
			if Input.is_action_pressed("up"):
				bR += 0.01
				print([mR,bR,Iterations],currentIteration)
			if Input.is_action_pressed("down"):
				bR -= 0.01
				print([mR,bR,Iterations],currentIteration)
		4:
			if Input.is_action_pressed("up"):
				Iterations += 5.0
				currentIteration += 5.0
				print([mR,bR,Iterations],currentIteration)
			if Input.is_action_pressed("down"):
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

func calculateError(iReference, examinee):
	var width = examinee.get_width()
	var height = examinee.get_height()
	
	iReference.unlock()
	iReference.resize(width,height,4)
	iReference.lock()
	
	var error = 0
	for x in range(0,width):
		for y in range(0,height):
			error += abs( colorSum(iReference.get_pixel(x,y)) - colorSum(examinee.get_pixel(x,y)) )
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

func processNeuralImage(iNeuralNet,iResolution,costEnum,reverseEnum):
	var NeuralOutputMatrix = []
	
	for x in range(0,iResolution):
		iNeuralNet.inputArray[0] = (x-(iResolution/2.0))*(graph_size/(iResolution/2.0))
		if printProgress:
			print(x+1, "/", iResolution)
		for y in range(0,iResolution):
			iNeuralNet.inputArray[1] = (y-(iResolution/2.0))*(graph_size/(iResolution/2.0))
			var outputs = iNeuralNet.processOutputs()
			for i in range(0,outputs.size()):
				NeuralOutputMatrix.append(outputs[i])
	
	#var normalizedNeuralOutputMatrix = normalize(NeuralOutputMatrix)
	var aOutputMatrix = activation(NeuralOutputMatrix)
	
	var Neural_img = Image.new()
	Neural_img.create_from_data(iResolution, iResolution, false, Image.FORMAT_RGB8, PoolByteArray(aOutputMatrix))
	Neural_img.lock()
	Neural_img.save_png("res://Images/aaa.png")
	
	var referenceImage = Image.new()
	referenceImage.load(referencePath)
	if costEnum == 1:
		if referencePath == "no input":
			push_error('(costEnum == 1) && (referencePath == "no input")')
			get_tree().quit()
	
	var sum_record
	if costEnum == 0:
		sum_record = calculateContrast(Neural_img)
	if costEnum == 1:
		sum_record = calculateError(referenceImage,Neural_img)
	
	print(sum_record)
	
	if reverseEnum == 0:
		pass
	if reverseEnum == 1:
		if sum_record[0] == sum_record[1]:
			pass
		else:
			iNeuralNet.ReverseLastNetParametersRandomStep()
	
	Neural_img.unlock()
	var txt = ImageTexture.new()
	Neural_img.resize(1000,1000,Image.INTERPOLATE_NEAREST)
	txt.create_from_image(Neural_img)
	texture = txt
