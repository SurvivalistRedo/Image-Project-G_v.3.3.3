extends Node

class_name Input_Handler

var s

func printSetup():
	var SF = Global.scoreFunction
	match(SF):
		0:
			print([Global.multRange,Global.biasRange,Global.Iterations,"contrast"])
		1:
			print([Global.multRange,Global.biasRange,Global.Iterations,"referenceError"])
		_:
			push_error("SF != (0 or 1)")

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
			if Input.is_action_pressed("Kp-Up"):
				Global.multRange += 0.01
				printSetup()
			if Input.is_action_pressed("Kp-Down") && (Global.multRange > 0):
				Global.multRange -= 0.01
				printSetup()
		2:
			if Input.is_action_pressed("Kp-Up"):
				Global.biasRange += 0.01
				printSetup()
			if Input.is_action_pressed("Kp-Down") && (Global.biasRange > 0):
				Global.biasRange -= 0.01
				printSetup()
		3:
			if Input.is_action_pressed("Kp-Up"):
				Global.Iterations += 10.0
				Global.currentIteration += 10.0
				printSetup()
			if Input.is_action_pressed("Kp-Down") && (Global.Iterations > 0):
				Global.Iterations -= 10.0
				Global.currentIteration -= 10.0
				printSetup()
		4:
			if Input.is_action_just_pressed("Kp-Up"):
				if Global.scoreFunction < 1:
					Global.scoreFunction += 1
					printSetup()
				else:
					printSetup()
			if Input.is_action_just_pressed("Kp-Down"):
				if Global.scoreFunction > 0:
					Global.scoreFunction -= 1
					printSetup()
				else:
					printSetup()
		_:
			pass
