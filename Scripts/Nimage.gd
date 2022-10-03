extends Sprite

var NeuralNet
var ImageHandler

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
	ImageHandler = Image_Handler.new()
	NeuralNet = Neural_Network.new()
	NeuralNet.initialize(2,[50,5,5,3])

func _process(delta):
	selector()
	
	if Input.is_action_just_pressed("ui_focus_next"):
		processNeuralImage(NeuralNet,contrast,dontReverseIfWorse)
	if Input.is_action_just_pressed("ui_accept"):
		resolution = 1000
		processNeuralImage(NeuralNet,contrast,dontReverseIfWorse)
	
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
		processNeuralImage(NeuralNet,contrast,dontReverseIfWorse)
	if Input.is_action_just_pressed("ui_right"):
		NeuralNet.NetParametersRandomStep()
		processNeuralImage(NeuralNet,contrast,dontReverseIfWorse)
	
	if Input.is_action_just_pressed("P"):
		NeuralNet.printNetwork()

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

func iterate():
	if x and currentIteration < Iterations:
		if currentIteration < Iterations:
			NeuralNet.NetParametersRandomStep()
			processNeuralImage(NeuralNet,referenceError,doReverseIfWorse)
			print(currentIteration+1,"/",Iterations)
			currentIteration += 1
		else:
			x = false
			currentIteration = 0
			processNeuralImage(NeuralNet,referenceError,dontReverseIfWorse)
			print(currentIteration+1,"/",Iterations)
	else:
		if Input.is_action_just_pressed("ui_up"):
			x = true
			currentIteration = 0

func processNeuralOutputMatrix(iNeuralNet):
	var NeuralOutputMatrix = []
	for x in range(0,resolution):
		iNeuralNet.inputArray[0] = (x-(resolution/2.0))*(graph_size/(resolution/2.0))
		if printProgress:
			print(x+1, "/", resolution)
		for y in range(0,resolution):
			iNeuralNet.inputArray[1] = (y-(resolution/2.0))*(graph_size/(resolution/2.0))
			var outputs = iNeuralNet.processOutputs()
			for i in range(0,outputs.size()):
				NeuralOutputMatrix.append(outputs[i])
	return NeuralOutputMatrix.duplicate(true)

func processNeuralImage(iNeuralNet,costEnum,reverseEnum):
	var aOutputMatrix = ImageHandler.normalize(processNeuralOutputMatrix(iNeuralNet))
	
	var Neural_img = Image.new()
	Neural_img.create_from_data(resolution, resolution, false, Image.FORMAT_RGB8, PoolByteArray(aOutputMatrix))
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
		ImageHandler.update(resolution,record,eRecord)
		sum_record = ImageHandler.calculateContrast(Neural_img)
		record = sum_record[1]
	if costEnum == 1:
		ImageHandler.update(resolution,record,eRecord)
		sum_record = ImageHandler.calculateError(referenceImage,Neural_img)
		eRecord = sum_record[1]
	
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
