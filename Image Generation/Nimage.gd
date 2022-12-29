extends Sprite

var NeuralNet
var ImageHandler
var InputHandler

var AF = arrayFunctions.new()

var record = 0
var eRecord = 0
var printSumRecord = true

var resolution = 10
var graph_size = 5
var graph_origin = Vector2(0,0)

var iterating = false
var anneal = true

var printProgress = true

enum {contrast,referenceError}
enum {dontReverseIfWorse,doReverseIfWorse}
enum {returnImage,returnTexture}

var saveDirectory = "no input"
var referencePath = "no input"

var parameterStepQueue = []

func _ready():
	get_tree().get_root().set_transparent_background(true)
	randomize()
	InputHandler = Input_Handler.new()
	ImageHandler = Image_Handler.new()
	NeuralNet = Neural_Network.new()
	NeuralNet.servingNimage = true
	NeuralNet.activation_function = 3 # {Sigmoid,GeLu,ReLu,Sin} = {0,1,2,3}
	NeuralNet.color_mode = 0 # {hsv,rgb} = {0,1}
	NeuralNet.initialize(2,[50,25,10,3])
	NeuralNet.backflowingNodeConnections()

func _process(_delta):
	InputHandler.selector()
	
	if Input.is_key_pressed(KEY_M):
		if anneal:
			anneal = false
			print("anneal off")
		else:
			anneal = true
			print("anneal on")
	
	graphInput()
	
	if Input.is_action_just_pressed("ui_focus_next"):
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
	if Input.is_action_just_pressed("ui_accept"):
		var buffer1 = resolution
		var buffer2 = printProgress
		resolution = 1000
		printProgress = true
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
		resolution = buffer1
		printProgress = buffer2
	
	if Input.is_action_pressed("X"):
		iterating = false
	iterate()
	
	if Input.is_action_just_pressed("S"):
		if printSumRecord:
			printSumRecord = false
		else:
			printSumRecord = true
	
	if Input.is_action_just_pressed("C"):
		match NeuralNet.color_mode:
			0:
				NeuralNet.color_mode = 1 # {hsv,rgb} = {0,1}
				print("NeuralNet.color_mode = 1")
			1:
				NeuralNet.color_mode = 0 # {hsv,rgb} = {0,1}
				print("NeuralNet.color_mode = 0")
			_:
				print("(NeuralNet.color_mode != 0) && (NeuralNet.color_mode != 1)")
	
	if Input.is_action_just_pressed("R"):
		clearRecords()
	
	if Input.is_action_pressed("ui_page_up"):
		if resolution < 10:
			resolution = 10
		else:
			resolution += 10
		print("Resolution = ",resolution)
	if Input.is_action_pressed("ui_page_down"):
		if resolution == 1:
			pass
		if resolution <= 10:
			resolution = 1
		else:
			resolution -= 10
		print("Resolution = ",resolution)
	
	if Input.is_action_just_pressed("ui_home"):
		printProgress = true
	if Input.is_action_just_pressed("ui_end"):
		printProgress = false
	
	if Input.is_action_just_pressed("Kp-Left"):
		NeuralNet.ReverseLastNetParametersRandomStep()
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
	if Input.is_action_just_pressed("Kp-Right"):
		NeuralNet.NetParametersRandomStep()
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
	
	if Input.is_action_just_pressed("P"):
		NeuralNet.printNetwork()

func graphInput():
	if Input.is_action_pressed("ui_down"):
		graph_origin += Vector2(0,-1)
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
		printViewportInfo()
	if Input.is_action_pressed("ui_up"):
		graph_origin += Vector2(0,1)
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
		printViewportInfo()
	if Input.is_action_pressed("ui_left"):
		graph_origin += Vector2(-1,0)
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
		printViewportInfo()
	if Input.is_action_pressed("ui_right"):
		graph_origin += Vector2(1,0)
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
		printViewportInfo()
	
	if Input.is_action_pressed("-"):
		graph_size -= 1
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
		printViewportInfo()
	if Input.is_action_pressed("+"):
		graph_size += 1
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
		printViewportInfo()

func iterate():
	if iterating and Global.currentIteration < Global.Iterations:
		if Global.currentIteration < Global.Iterations:
			if parameterStepQueue == []:
				parameterStepQueue.append(NeuralNet.NetParametersRandomStep().duplicate(true))
				
				if parameterStepQueue.size() == 1:
					parameterStepQueue[0] = AF.multiplyArray(parameterStepQueue[0],-1.0).duplicate(true)
				elif parameterStepQueue.size() > 1:
					parameterStepQueue[-1] = AF.multiplyArray(parameterStepQueue[-1],-1.0).duplicate(true)
				else:
					push_error("wahhh")
					get_tree().quit()
				
				if processNeuralImage(NeuralNet,Global.scoreFunction,doReverseIfWorse):
					pass
				else:
					if parameterStepQueue.size() == 1:
						parameterStepQueue.remove(0)
					elif parameterStepQueue.size() > 1:
						parameterStepQueue.remove(-1)
					else:
						push_error("wahhh")
						get_tree().quit()
				print(Global.currentIteration+1,"/",Global.Iterations)
				Global.currentIteration += 1
			elif parameterStepQueue != []:
				NeuralNet.NetAddParameterStep(parameterStepQueue[0],1.0,true)
				parameterStepQueue.remove(0)
				processNeuralImage(NeuralNet,Global.scoreFunction,doReverseIfWorse)
				print(Global.currentIteration+1,"/",Global.Iterations)
				Global.currentIteration += 1
		else:
			iterating = false
			Global.currentIteration = 0
			processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
			print(Global.currentIteration+1,"/",Global.Iterations)
	else:
		if Input.is_action_just_pressed("Kp-Add"):
			iterating = true
			Global.currentIteration = 0

func clearRecords():
	print([record,eRecord])
	record = 0
	eRecord = 0
	print([record,eRecord])

func printViewportInfo():
	print("(",graph_origin.x,",",graph_origin.y,")","(±",graph_size,",±",graph_size,")")

func processNeuralOutputMatrix(iNeuralNet):
	var NeuralOutputMatrix = []
	for y in range(0,resolution):
		var y_pos = -(y-(resolution/2.0))*(graph_size/(resolution/2.0)) + graph_origin.y
		iNeuralNet.inputArray[1] = y_pos
		if printProgress:
			print(y+1, "/", resolution)
		for x in range(0,resolution):
			var x_pos = (x-(resolution/2.0))*(graph_size/(resolution/2.0)) + graph_origin.x
			iNeuralNet.inputArray[0] = x_pos
			var outputs = iNeuralNet.processOutputs()
			for i in range(0,outputs.size()):
				NeuralOutputMatrix.append(outputs[i])
	return NeuralOutputMatrix.duplicate(true)

func processNeuralImage(iNeuralNet,costEnum,reverseEnum):
	var OutputMatrix = processNeuralOutputMatrix(iNeuralNet)
	
	var Neural_img = Image.new()
	Neural_img.create_from_data(resolution, resolution, false, Image.FORMAT_RGB8, PoolByteArray(ImageHandler.ONEtoTWOFIFTYFIVE(OutputMatrix)))
	Neural_img.lock()
	Neural_img.save_png(saveDirectory + "/aaa.png")
	
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
		sum_record = ImageHandler.calculateError(referenceImage,Neural_img,saveDirectory)
		eRecord = sum_record[1]
	
	var isWorse
	if reverseEnum == 0:
		pass
	if reverseEnum == 1:
		if sum_record[0] == sum_record[1]:
			isWorse = false
		else:
			if (anneal) && (rand_range(0.0,1.0) < sum_record[0]/10.0): # do following code with a % chance
				sum_record[1] = sum_record[0]
				if costEnum == 0:
					record = sum_record[1]
				if costEnum == 1:
					eRecord = sum_record[1]
				isWorse = false
			else:
				iNeuralNet.ReverseLastNetParametersRandomStep()
				isWorse = true
	
	if printSumRecord:
		print(sum_record)
	
	Neural_img.unlock()
	var txt = ImageTexture.new()
	Neural_img.resize(1000,1000,Image.INTERPOLATE_NEAREST)
	txt.create_from_image(Neural_img)
	texture = txt
	
	return isWorse
