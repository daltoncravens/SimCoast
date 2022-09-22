extends FileDialog

var lineEdit
var okButton


func _ready():
	okButton = get_ok()
	okButton.text = "Save"
	get_close_button().hide()
