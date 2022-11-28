extends Sprite

var NeuralNet
var ImageHandler
var InputHandler

var record = 0
var eRecord = 0

var resolution = 50
var graph_size = 5
var graph_origin = Vector2(0,0)

var x = false

var printProgress = true

enum {contrast,referenceError}
enum {dontReverseIfWorse,doReverseIfWorse}
enum {returnImage,returnTexture}

var referencePath = "no input"

func _ready():
	get_tree().get_root().set_transparent_background(true)
	randomize()
	InputHandler = Input_Handler.new()
	ImageHandler = Image_Handler.new()
	NeuralNet = Neural_Network.new()
	NeuralNet.initialize(2,[20,20,10,3])

func _process(_delta):
	InputHandler.selector()
	
	if Input.is_action_pressed("ui_down"):
		graph_origin += Vector2(0,-1)
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
	if Input.is_action_pressed("ui_up"):
		graph_origin += Vector2(0,1)
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
	if Input.is_action_pressed("ui_left"):
		graph_origin += Vector2(-1,0)
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
	if Input.is_action_pressed("ui_right"):
		graph_origin += Vector2(1,0)
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
	
	if Input.is_action_pressed("-"):
		graph_size -= 1
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
	if Input.is_action_pressed("+"):
		graph_size += 1
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
	
	if Input.is_action_just_pressed("ui_focus_next"):
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
	if Input.is_action_just_pressed("ui_accept"):
		resolution = 1000
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
	
	if Input.is_action_pressed("X"):
		x = false
	iterate()
	
	if Input.is_action_just_pressed("C"):
		clearRecords()
	
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
	
	if Input.is_action_just_pressed("Kp-Left"):
		NeuralNet.ReverseLastNetParametersRandomStep()
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
	if Input.is_action_just_pressed("Kp-Right"):
		NeuralNet.NetParametersRandomStep()
		processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
	
	if Input.is_action_just_pressed("P"):
		NeuralNet.printNetwork()

func iterate():
	if x and Global.currentIteration < Global.Iterations:
		if Global.currentIteration < Global.Iterations:
			NeuralNet.NetParametersRandomStep()
			processNeuralImage(NeuralNet,Global.scoreFunction,doReverseIfWorse)
			print(Global.currentIteration+1,"/",Global.Iterations)
			Global.currentIteration += 1
		else:
			x = false
			Global.currentIteration = 0
			processNeuralImage(NeuralNet,Global.scoreFunction,dontReverseIfWorse)
			print(Global.currentIteration+1,"/",Global.Iterations)
	else:
		if Input.is_action_just_pressed("Kp-Add"):
			x = true
			Global.currentIteration = 0

func clearRecords():
	print([record,eRecord])
	record = 0
	eRecord = 0
	print([record,eRecord])

func processNeuralOutputMatrix(iNeuralNet):
	var NeuralOutputMatrix = []
	for x in range(0,resolution):
		var x_pos = (x-(resolution/2.0))*(graph_size/(resolution/2.0)) + graph_origin.x
		iNeuralNet.inputArray[0] = x_pos
		if printProgress:
			print(x+1, "/", resolution)
		for y in range(0,resolution):
			var y_pos = (y-(resolution/2.0))*(graph_size/(resolution/2.0)) + graph_origin.y
			iNeuralNet.inputArray[1] = y_pos
			var outputs = iNeuralNet.processOutputs()
			for i in range(0,outputs.size()):
				if x % 2 == 0:
					NeuralOutputMatrix.append(outputs[i])
				else:
					NeuralOutputMatrix.append(0.0)
	return NeuralOutputMatrix.duplicate(true)

func processNeuralImage(iNeuralNet,costEnum,reverseEnum):
	var OutputMatrix = processNeuralOutputMatrix(iNeuralNet)
	
	var Neural_img = Image.new()
	Neural_img.create_from_data(resolution, resolution, false, Image.FORMAT_RGB8, PoolByteArray(ImageHandler.ONEtoTWOFIFTYFIVE(OutputMatrix)))
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
