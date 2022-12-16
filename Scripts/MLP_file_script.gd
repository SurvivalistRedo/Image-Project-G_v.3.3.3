extends Resource

class_name MLP_file

export var SAVE_NAME = "DEFAULT_FILE_NAME"

export var SAVEDnetworkArray = []
export var SNAinfo = []

func save_networkArray(s_n = SAVE_NAME):
	SAVE_NAME = s_n
	ResourceSaver.save("res://" + SAVE_NAME + ".tres", self)
