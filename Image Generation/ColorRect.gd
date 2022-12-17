extends ColorRect

func _process(delta):
	color = Color.from_hsv(get_global_mouse_position().x/1000.0,1.0,1.0)
