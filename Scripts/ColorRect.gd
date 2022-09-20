extends ColorRect

var NeuralNet1

var img
var record = 0
var eRecord = 0

var resolution = 50
var graph_size = 1500

var Iterations = 10
var currentIteration = 10
var x = false

var s

var oR = 0.0
var mR = 100.0
var bR = 100.0

var printProgress = true

func _ready():
	get_tree().get_root().set_transparent_background(true)
	randomize()
	NeuralNet1 = NeuralNet.new()
	NeuralNet1.initialize([2,50,10,1])
	NeuralNet1.NetVarArrayRandomStep()
	processNeuralImage()

func _process(delta):
	selector()
	
	if Input.is_action_just_pressed('ui_focus_next'):
		processNeuralImage()
	
	if x or currentIteration < Iterations:
		if currentIteration < Iterations:
			NeuralNet1.NetVarArrayRandomStep()
			processNeuralImage()
			currentIteration += 1
		else:
			x = false
			currentIteration = 0
			processNeuralImage()
	else:
		if Input.is_action_just_pressed('ui_up'):
			x = true
	
	if Input.is_action_just_pressed('ui_accept'):
		resolution = 1000
		processNeuralImage()
	
	if Input.is_action_just_pressed('ui_page_up'):
		resolution += 10
		print("Resolution = ",resolution)
	if Input.is_action_just_pressed('ui_page_down'):
		resolution -= 10
		print("Resolution = ",resolution)
	
	if Input.is_action_just_pressed('ui_home'):
		printProgress = true
	if Input.is_action_just_pressed('ui_end'):
		printProgress = false
	
	if Input.is_action_just_pressed('ui_left'):
		NeuralNet1.ReverseLastNetVarArrayRandomStep()
		processNeuralImage()

func s(rgb):
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
			if Input.is_action_pressed('up'):
				oR += 0.05
				print([oR,mR,bR,Iterations],currentIteration)
			if Input.is_action_pressed('down'):
				oR -= 0.05
				print([oR,mR,bR,Iterations],currentIteration)
		2:
			if Input.is_action_pressed('up'):
				mR += 0.01
				print([oR,mR,bR,Iterations],currentIteration)
			if Input.is_action_pressed('down'):
				mR -= 0.01
				print([oR,mR,bR,Iterations],currentIteration)
		3:
			if Input.is_action_pressed('up'):
				bR += 0.01
				print([oR,mR,bR,Iterations],currentIteration)
			if Input.is_action_pressed('down'):
				bR -= 0.01
				print([oR,mR,bR,Iterations],currentIteration)
		4:
			if Input.is_action_pressed('up'):
				Iterations += 1.0
				currentIteration += 10.0
				print([oR,mR,bR,Iterations],currentIteration)
			if Input.is_action_pressed('down'):
				Iterations -= 1.0
				print([oR,mR,bR,Iterations],currentIteration)
		_:
			pass
	NeuralNet1.oR = oR
	NeuralNet1.mR = oR
	NeuralNet1.bR = oR

func calculateContrast(reference):
	var width = reference.get_width()
	var height = reference.get_height()
	
	var cimg = Image.new()
	cimg.create(width, height, false, Image.FORMAT_RGB8)
	cimg.lock()
	cimg.copy_from(reference)
	cimg.unlock()
	cimg.resize(10,10,0)
	cimg.lock()
	
	var c_buffer = 0
	var sum = 0
	for x in range(0,10):
		#print(round(x/10.0*100.0),"%")
		for y in range(0,10):
			sum += abs( s(cimg.get_pixel(x,y) - Color(c_buffer)) )
			c_buffer = cimg.get_pixel(x,y)
	if sum > record:
		record = sum
	print("(contrast ", sum, ") (record ", record, ")")
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
			error += abs( s(reference.get_pixel(x,y)) - s(examinee.get_pixel(x,y)) )
	error = error/pow(resolution,2.0)
	if error < eRecord or eRecord == 0:
		eRecord = error
	return [error,eRecord]

func processNeuralImage():
	img = Image.new()
	img.create(resolution, resolution, false, Image.FORMAT_RGB8)
	img.lock()
	
	for x in range(0,resolution):
		NeuralNet1.array[0][0].Value = (x-(resolution/2.0))*(graph_size/(resolution/2.0))
		if printProgress:
			print(x, "/", resolution)
		for y in range(0,resolution):
			NeuralNet1.array[0][1].Value = (y-(resolution/2.0))*(graph_size/(resolution/2.0))
			var color = NeuralNet1.processNet()
			img.set_pixel(x,y,Color(color[0], color[0], 0.0, 1.0))
	
	var rad = Image.new()
	rad.create(600,600,false,Image.FORMAT_RGB8)
	rad.lock()
	rad = load('res://Radiation_warning_symbol.png')
	
	#var texture = ImageTexture.new()
	#texture.load('res://Radiation_warning_symbol.png')
	
	var sum_record = calculateError(rad,img)
	print(sum_record)
	if sum_record[0] == sum_record[1]:
		x = false
	else:
		NeuralNet1.ReverseLastNetVarArrayRandomStep()
	
	img.unlock()
	img.resize(1000,1000,0)
	img.save_png('res://aaa.png')
