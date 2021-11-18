extends AcceptDialog

var x_button = self.get_close_button()
var back_button = get_ok()
# Called when the node enters the scene tree for the first time.
func _ready():
	back_button.text = "Back"
	
func _on_OptionsButton_pressed():
	popup()
	x_button.hide()
