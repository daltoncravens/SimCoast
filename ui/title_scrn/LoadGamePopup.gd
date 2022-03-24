extends FileDialog


func _ready():
	pass 

func _on_LoadGameButton_pressed():
	popup_centered()

func _on_LoadGamePopup_file_selected(path:String):
	if ".json" in path:
		SaveLoad.loadData(path)
		var _err = get_tree().change_scene("res://start_map.tscn")
	else:
		OS.alert('File chosen is of wrong type, the game specifically uses JSON files.', 'Warning')
