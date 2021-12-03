extends HBoxContainer

export(ButtonGroup) var group

func _ready():
	for i in group.get_buttons():
		i.connect("pressed", self, "button_pressed")

func button_pressed():
	match group.get_pressed_button().get_name():
		'Pause_Button':
			Global.gamePaused = true
			print("Pausing game")
		'Play_Button':
			Global.gamePaused = false
			Global.gameSpeed = 20000
			print("Game Speed: Normal")
		'Fast_Forward_Button':
			Global.gamePaused = false
			Global.gameSpeed = 60000
			print("Game Speed: Fast")
