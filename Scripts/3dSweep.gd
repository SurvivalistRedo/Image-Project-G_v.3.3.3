extends Node

class_name varSweep

func mod(x,y):
	var a = x/y
	return (a - floor(a)) * y

func generateDimensionSet(sc, xe=1.0, ye=1.0, ze=1.0):
	
	var crash = false
	if sc < 0.0:
		push_error("sc < 0.0")
		crash = true
	if (sc != floor(sc)) or (sc != ceil(sc)):
		push_error("(sc != floor(sc)) or (sc != ceil(sc))")
		crash = true
	if crash:
		get_tree().quit
	
	var set = []
	for z in (sc + 1.0):
		for y in (sc + 1.0):
			for x in (sc + 1.0):
				set.append([x/sc*xe,y/sc*ye,z/sc*ze])
	
	return set
