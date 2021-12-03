extends HBoxContainer

export(ButtonGroup) var group

func _ready():
	print(group.get_buttons())
