extends FileDialog

func _on_FileDialog_file_selected(path):
	get_parent().get_node("Nimage").referencePath = path
