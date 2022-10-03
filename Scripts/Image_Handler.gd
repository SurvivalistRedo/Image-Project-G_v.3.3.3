extends Node

class_name Image_Handler

var resolution = 0

var record = 0
var eRecord = 0

func update(i_resolution,i_record,i_eRecord):
	resolution = i_resolution
	record = i_record
	eRecord = i_eRecord

func findMinMax(array):
	var Max = null
	var Min = null
	for n in range(0,array.size()):
		if Max == null:
			Max = array[n]
		else:
			if array[n] > Max:
				Max = array[n]
		if Min == null:
			Min = array[n]
		else:
			if array[n] < Min:
				Min = array[n]
	return [Min,Max]
func normalize(data):
	var array_buffer = []
	var MinMax = findMinMax(data)
	if (MinMax[0] - MinMax[1]) == 0:
		push_error("(MinMax[0] - MinMax[1]) == 0")
		return data.duplicate(true)
	for n in range(0,data.size()):
		array_buffer.append(255.0*((data[n]-MinMax[0])/(MinMax[1]-MinMax[0])))
	return array_buffer.duplicate(true)

func activation(data):
	var array_buffer = []
	for n in range(0,data.size()):
		array_buffer.append( 255.0 * max(min(1.0/(1.0+pow(2.718,-4*(data[n]/255.0)+2.0)),1.0),0.0) )
	return array_buffer.duplicate(true)

func colorSum(rgb):
	return rgb.r+rgb.g+rgb.b
func calculateContrast(reference):
	var sum = 0
	var imgBuffer = Image.new()
	imgBuffer.create(reference.get_width(),reference.get_height(),false,Image.FORMAT_RGB8)
	imgBuffer.copy_from(reference)
	imgBuffer.lock()
	for y in range(0,reference.get_height()):
		#if round(float(y+1.0)/reference.get_height()*1000.0)/10.0 == round(round(float(y+1.0)/reference.get_height()*1000.0)/10.0):
		#	print(round(float(y+1.0)/reference.get_height()*1000.0)/10.0,".0","%")
		#else:
		#	print(round(float(y+1.0)/reference.get_height()*1000.0)/10.0,"%")
		for x in range(0,reference.get_width()):
			for j in [-1,0,1]:
				if (y+j >= 0) && (y+j < reference.get_height()):
					for i in [-1,0,1]:
						if (x+i >= 0) && (x+i < reference.get_width()):
							sum += abs(colorSum(imgBuffer.get_pixel(x,y))-colorSum(imgBuffer.get_pixel(x+i,y+j)))
	sum = sum / ( reference.get_width() * reference.get_height() )
	if sum > record:
		record = sum
	return [sum,record]
func calculateError(iReference, examinee):
	var width = examinee.get_width()
	var height = examinee.get_height()
	
	iReference.unlock()
	iReference.resize(width,height,4)
	iReference.lock()
	
	var error = 0
	for x in range(0,width):
		for y in range(0,height):
			error += abs( colorSum(iReference.get_pixel(x,y)) - colorSum(examinee.get_pixel(x,y)) )
	error = error/pow(resolution,2.0)
	if error < eRecord or eRecord == 0:
		eRecord = error
	return [error,eRecord]
