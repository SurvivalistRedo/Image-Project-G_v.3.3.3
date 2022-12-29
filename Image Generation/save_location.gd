extends FileDialog

func _on_save_location_dir_selected(dir):
	get_parent().get_node("Nimage").saveDirectory = dir
	get_node("reference_location").popup(Rect2(50,50,900,900))
