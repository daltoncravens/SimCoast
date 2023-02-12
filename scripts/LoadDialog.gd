extends FileDialog

var lineEdit

func _ready():
	lineEdit = get_line_edit()
	lineEdit.grab_focus()
