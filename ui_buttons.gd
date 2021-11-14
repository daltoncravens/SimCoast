extends Control

export(ButtonGroup) var group

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in group.get_buttons():
		i.connect("pressed", self, "button_pressed")

func button_pressed():
	match group.get_pressed_button().get_name():
		'dirt_button':
			Global.mapTool = 1
		'sand_button':
			Global.mapTool = 2
		'water_button':
			Global.mapTool = 3
		'rzone_button':
			Global.mapTool = 4
		'czone_button':
			Global.mapTool = 5
		'izone_button':
			Global.mapTool = 6
		'park_button':
			Global.mapTool = 7
		'road_button':
			Global.mapTool = 8
		'ocean_button':
			Global.mapTool = 9
