extends FileDialog

func _on_reference_location_file_selected(path):
	get_parent().get_parent().get_node("Nimage").referencePath = path
