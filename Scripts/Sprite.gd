extends Sprite

var s

var lr = 1
var lg = 1
var lb = 1

func _process(_delta):
	var textur = ImageTexture.new()
	var img = get_parent().img
	textur.create_from_image(img)
	texture = textur
	
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
			lr = get_global_mouse_position().x/1000
		2:
			lg = get_global_mouse_position().x/1000
		3:
			lb = get_global_mouse_position().x/1000
		_:
			pass
	if false:
		modulate = Color(lr,lg,lb)
