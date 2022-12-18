extends Node2D

func mouse_angle():
	var mp = get_global_mouse_position() - Vector2(500,500) # mouse position with origin at center of screen
	mp.y = mp.y * -1.0 # reflect mp.y about the x axis to make the coordinates match a regular graph
	if (mp.x == 0.0) && (mp.y == 0.0):
		return null
	elif mp.x == 0.0:
		if mp.y > 0.0:
			return PI / 2.0
		if mp.y < 0.0:
			return PI + (PI / 2.0)
	elif mp.x >= 0.0:
		if mp.y >= 0.0:
			return atan(mp.y/mp.x)
		else:
			return atan(mp.y/mp.x)+(2.0*PI)
	else:
		return atan(mp.y/mp.x)+(1.0*PI)

func mod(x,y):
	if y == 0.0:
		return null
	var quotient = x/y
	return y * (quotient - floor(quotient))

func step(x,steps,upper_bound):
	return floor((mod(x,upper_bound)/upper_bound)*steps)

func _process(_delta):
	var clicked = null
	if Input.is_action_pressed("Left Click"):
		clicked = true
	else:
		clicked = false
	
	var ma = mouse_angle() # mouse angle with origin at center of screen
	if ma == null:
		pass
	else:
		var array_size = Global.scenes.size()
		if array_size > 0:
			ma = step(ma,array_size,2.0*PI)
			var brightness = (ma / (array_size-1.0)) / 2.0
			get_node("ColorRect").modulate = Color.from_hsv(brightness,1.0,0.1)
			get_node("RichTextLabel").text = Global.scenes[ma]
			if clicked:
				get_tree().change_scene(Global.scenes[ma])
		else:
			pass
