extends Node

class_name Input_Handler

var s
var cooldown = [[0.0,0.0,0.0,0.0,0.0],[3.0,3.0,10.0,0.0,0.0]]

func printSetup():
	var SF = Global.scoreFunction
	match(SF):
		0:
			print([Global.multRange,Global.biasRange,Global.step_size,Global.Iterations,"contrast"])
		1:
			print([Global.multRange,Global.biasRange,Global.step_size,Global.Iterations,"referenceError"])
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
	if Input.is_action_pressed("5"):
		s = 5
	
	for i in cooldown[0].size():
		if cooldown[0][i] > 0.0:
			cooldown[0][i] -= 1.0
		elif cooldown[0][i] < 0.0:
			cooldown[0][i] = 0.0
	
	match(s):
		1:
			if cooldown[0][0] == 0.0:
				if Input.is_action_pressed("Kp-Up"):
					Global.multRange += Global.step_size
					cooldown[0][0] = cooldown[1][0]
					printSetup()
				if Input.is_action_pressed("Kp-Down") && (Global.multRange > 0):
					Global.multRange -= Global.step_size
					cooldown[0][0] = cooldown[1][0]
					printSetup()
		2:
			if cooldown[0][1] == 0.0:
				if Input.is_action_pressed("Kp-Up"):
					Global.biasRange += Global.step_size
					cooldown[0][1] = cooldown[1][1]
					printSetup()
				if Input.is_action_pressed("Kp-Down") && (Global.biasRange > 0):
					Global.biasRange -= Global.step_size
					cooldown[0][1] = cooldown[1][1]
					printSetup()
		3:
			if cooldown[0][2] == 0.0:
				if Input.is_action_pressed("Kp-Up") && (Global.step_size < 100.0):
					Global.step_size = Global.step_size * 10.0
					cooldown[0][2] = cooldown[1][2]
					printSetup()
				if Input.is_action_pressed("Kp-Down") && (Global.step_size > 0.00001):
					Global.step_size = Global.step_size / 10.0
					cooldown[0][2] = cooldown[1][2]
					printSetup()
		4:
			if cooldown[0][3] == 0.0:
				if Input.is_action_pressed("Kp-Up"):
					Global.Iterations += 10.0
					Global.currentIteration += 10.0
					cooldown[0][3] = cooldown[1][3]
					printSetup()
				if Input.is_action_pressed("Kp-Down") && (Global.Iterations > 0):
					Global.Iterations -= 10.0
					Global.currentIteration -= 10.0
					cooldown[0][3] = cooldown[1][3]
					printSetup()
		5:
			if cooldown[0][4] == 0.0:
				if Input.is_action_just_pressed("Kp-Up"):
					if Global.scoreFunction < 1:
						Global.scoreFunction += 1
						cooldown[0][4] = cooldown[1][4]
						printSetup()
					else:
						printSetup()
				if Input.is_action_just_pressed("Kp-Down"):
					if Global.scoreFunction > 0:
						Global.scoreFunction -= 1
						cooldown[0][4] = cooldown[1][4]
						printSetup()
					else:
						printSetup()
		_:
			pass
