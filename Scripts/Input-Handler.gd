extends Node

class_name Input_Handler

var s

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
			if Input.is_action_pressed("up"):
				Global.multRange += 0.01
				print([Global.multRange,Global.biasRange,Global.Iterations])
			if Input.is_action_pressed("down"):
				Global.multRange -= 0.01
				print([Global.multRange,Global.biasRange,Global.Iterations])
		2:
			if Input.is_action_pressed("up"):
				Global.biasRange += 0.01
				print([Global.multRange,Global.biasRange,Global.Iterations])
			if Input.is_action_pressed("down"):
				Global.biasRange -= 0.01
				print([Global.multRange,Global.biasRange,Global.Iterations])
		3:
			if Input.is_action_pressed("up"):
				Global.Iterations += 5.0
				Global.currentIteration += 5.0
				print([Global.multRange,Global.biasRange,Global.Iterations])
			if Input.is_action_pressed("down"):
				Global.Iterations -= 5.0
				Global.currentIteration -= 5.0
				print([Global.multRange,Global.biasRange,Global.Iterations])
		_:
			pass
