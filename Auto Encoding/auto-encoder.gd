extends Node2D

var NeuralNet = Neural_Network.new()
var archivedNet = MLP_file.new()

var AF = arrayFunctions.new()

var gradientStep = null
var loss = null
var steps = 0

var sum_archive = []

var data_set = []
var epoch = 1

var lHasBeenPressed = false
var explore = false
var randomTest = false

func _ready(should_load = false):
	var dsweep = varSweep.new()
	data_set = dsweep.generateDimensionSet(10.0).duplicate(true)
	NeuralNet = Neural_Network.new()
	NeuralNet.activation_function = 1 # 1 = GeLu
	randomize()
	var q = 30.0
	NeuralNet.initialize(3,[q,q,3,q,q,3],1.0/q)
	if should_load:
		gradientStep = null
		loss = null
		steps = 0
		
		sum_archive = []
		
		epoch = 1
		
		archivedNet = ResourceLoader.load(archivedNet.SAVE_PATH)
		NeuralNet.networkArray = archivedNet.SAVEDnetworkArray.duplicate(true)

func bitch():
	if epoch > 10:
		
		if archivedNet.SAVEDnetworkArray == []:
			archivedNet.SNAinfo = []
			archivedNet.SNAinfo.append(sum_archive.min())
			
			archivedNet.SAVEDnetworkArray = NeuralNet.networkArray.duplicate(true)
			
			archivedNet.save_networkArray("SnA")
			print("Saved")
		
		else:
			if sum_archive.min() < archivedNet.SNAinfo[0]:
				archivedNet.SNAinfo = []
				archivedNet.SNAinfo.append(sum_archive.min())
				
				archivedNet.SAVEDnetworkArray = NeuralNet.networkArray.duplicate(true)
				
				archivedNet.save_networkArray("SnA")
				print("Saved")
			else:
				print("Skipped")
		
		epoch = 1
		sum_archive = []
		_ready()

func _process(delta):
	
	if Input.is_action_pressed("ui_select"):
		return
	
	if Input.is_key_pressed(KEY_L):
		if lHasBeenPressed:
			pass
		else:
			lHasBeenPressed = true
			print("L1")
			_ready(true)
	else:
		lHasBeenPressed = false
	
	if Input.is_action_just_pressed("E"):
		if explore:
			explore = false
			print("Explore Off")
		else:
			explore = true
			print("Explore On")
	
	if Input.is_action_just_pressed("S"):
		print("S1")
		archivedNet.SAVEDnetworkArray = NeuralNet.networkArray
		archivedNet.SNAinfo = sum_archive.min()
		archivedNet.save_networkArray("SnA")
	
	if Input.is_action_just_pressed("R"):
		if randomTest:
			randomTest = false
			print("randomTest Off")
		else:
			randomTest = true
			print("randomTest On")
	
	var rgbTrue = []
	if randomTest:
		for i in 3:
			rgbTrue.append(rand_range(0,1))
	else:
		rgbTrue = data_set[steps].duplicate(true)
	
	var rgbTrueC = Color(rgbTrue[0],rgbTrue[1],rgbTrue[2])
	
	var hsvTrue = []
	hsvTrue.append(rgbTrueC.h)
	hsvTrue.append(rgbTrueC.s)
	hsvTrue.append(rgbTrueC.v)
	
	for i in 3:
		NeuralNet.inputArray[i] = rgbTrue[i]
	var netOutputs = NeuralNet.processOutputs()
	
	var netHSVestimate = []
	for i in 3:
		netHSVestimate.append(netOutputs[2][i])
	
	var netRGBestimate = []
	for i in 3:
		netRGBestimate.append(netOutputs[5][i])
	
	get_node("d11").color = Color(NeuralNet.inputArray[0],NeuralNet.inputArray[0],NeuralNet.inputArray[0])
	get_node("d12").color = Color(NeuralNet.inputArray[1],NeuralNet.inputArray[1],NeuralNet.inputArray[1])
	get_node("d13").color = Color(NeuralNet.inputArray[2],NeuralNet.inputArray[2],NeuralNet.inputArray[2])
	get_node("d21").color = Color(netHSVestimate[0],netHSVestimate[0],netHSVestimate[0])
	get_node("d22").color = Color(netHSVestimate[1],netHSVestimate[1],netHSVestimate[1])
	get_node("d23").color = Color(netHSVestimate[2],netHSVestimate[2],netHSVestimate[2])
	get_node("d31").color = Color(netRGBestimate[0],netRGBestimate[0],netRGBestimate[0])
	get_node("d32").color = Color(netRGBestimate[1],netRGBestimate[1],netRGBestimate[1])
	get_node("d33").color = Color(netRGBestimate[2],netRGBestimate[2],netRGBestimate[2])
	
	var l = 0.01
	
	if false:
		#var gs0 = NeuralNet.gradientDescentSingleLayer(0,netOutputs[4],l)
		#var gs1 = NeuralNet.gradientDescentSingleLayer(1,netOutputs[3],l)
		#var gs2 = NeuralNet.gradientDescentSingleLayer(2,hsvTrue,l)
		#var gs3 = NeuralNet.gradientDescentSingleLayer(3,netOutputs[1],l)
		#var gs4 = NeuralNet.gradientDescentSingleLayer(4,netOutputs[0],l)
		#var gs5 = NeuralNet.gradientDescentSingleLayer(5,rgbTrue,l)
		#if gradientStep == null:
		#	gradientStep = gs0 + gs1 + gs2 + gs3 + gs4 + gs5
		#else:
		#	gradientStep += gs0 + gs1 + gs2 + gs3 + gs4 + gs5
		pass
	
	var gs3 = NeuralNet.gradientDescentSingleLayer(3,netOutputs[1],l)
	var gs4 = NeuralNet.gradientDescentSingleLayer(4,netOutputs[0],l)
	var gs5 = NeuralNet.gradientDescentSingleLayer(5,rgbTrue,l)
	if gradientStep == null:
		gradientStep = AF.pairArrayAdd(AF.pairArrayAdd(gs3,gs4),gs5)
	else:
		gradientStep = AF.pairArrayAdd(gradientStep,AF.pairArrayAdd(AF.pairArrayAdd(gs3,gs4),gs5))
	steps += 1
	
	if loss == null:
		loss = AF.pairArrayAbsoluteDifference(rgbTrue,netRGBestimate)
		#loss = AF.pairArrayAbsoluteDifference(rgbTrue,[0.5,0.5,0.5])
	else:
		loss = AF.pairArrayAdd(loss,AF.pairArrayAbsoluteDifference(rgbTrue,netRGBestimate))
		#loss = AF.pairArrayAdd(loss,AF.pairArrayAbsoluteDifference(rgbTrue,[0.5,0.5,0.5]))
	
	if steps >= data_set.size() - 1.0:
		NeuralNet.NetAddParameterStep(gradientStep,steps+1.0)
		
		var sum = 0
		for i in loss.size():
			sum += loss[i]
		sum_archive.append(sum/(steps+1.0))
		
		print(Vector2(epoch,sum/(steps+1.0)))
		epoch += 1
		
		gradientStep = null
		loss = null
		steps = 0
		
		if explore:
			bitch()
