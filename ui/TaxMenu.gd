extends Control

var is_displayed = false setget set_is_displayed

func _unhandled_input(event):
	if event.is_action_pressed("taxMenu"):
		self.is_displayed = !is_displayed

func set_is_displayed(value):
	is_displayed = value
	#get_tree().paused = is_displayed
	visible = is_displayed

func _on_ExitTaxMenu_pressed():
	self.is_displayed = false

func _on_Inc_pressed(extra_arg_0):
	match extra_arg_0:
		0: #light res prop
			Econ.adjust_individual_tax_rate(extra_arg_0, 0)
		1: #light res income
			Econ.adjust_individual_tax_rate(extra_arg_0, 0)
		2: #heavy res prop
			Econ.adjust_individual_tax_rate(extra_arg_0, 0)
		3: #heavy res income
			Econ.adjust_individual_tax_rate(extra_arg_0, 0)
		4: #light com prop
			Econ.adjust_individual_tax_rate(extra_arg_0, 0)
		5: #light com income
			Econ.adjust_individual_tax_rate(extra_arg_0, 0)
		6: #heavy com prop
			Econ.adjust_individual_tax_rate(extra_arg_0, 0)
		7: #heavy com income
			Econ.adjust_individual_tax_rate(extra_arg_0, 0)
	update_tax_values()

func _on_Dec_pressed(extra_arg_0):
	match extra_arg_0:
		0: #light res prop
			Econ.adjust_individual_tax_rate(extra_arg_0, 1)
		1: #light res income
			Econ.adjust_individual_tax_rate(extra_arg_0, 1)
		2: #heavy res prop
			Econ.adjust_individual_tax_rate(extra_arg_0, 1)
		3: #heavy res income
			Econ.adjust_individual_tax_rate(extra_arg_0, 1)
		4: #light com prop
			Econ.adjust_individual_tax_rate(extra_arg_0, 1)
		5: #light com income
			Econ.adjust_individual_tax_rate(extra_arg_0, 1)
		6: #heavy com prop
			Econ.adjust_individual_tax_rate(extra_arg_0, 1)
		7: #heavy com income
			Econ.adjust_individual_tax_rate(extra_arg_0, 1)
	update_tax_values()

func update_tax_values():
	$CenterContainer/VBoxContainer/LResProp/Label.text = str(Econ.LIGHT_RES_PROPERTY_RATE).pad_decimals(2)
	$CenterContainer/VBoxContainer/LResInc/Label.text = str(Econ.LIGHT_RES_INCOME_RATE).pad_decimals(2)
	$CenterContainer/VBoxContainer/HResProp/Label.text = str(Econ.HEAVY_RES_PROPERTY_RATE).pad_decimals(2)
	$CenterContainer/VBoxContainer/HResInc/Label.text = str(Econ.HEAVY_RES_INCOME_RATE).pad_decimals(2)
	$CenterContainer/VBoxContainer/LComProp/Label.text = str(Econ.LIGHT_COM_PROPERTY_RATE).pad_decimals(2)
	$CenterContainer/VBoxContainer/LComInc/Label.text = str(Econ.LIGHT_COM_INCOME_RATE).pad_decimals(2)
	$CenterContainer/VBoxContainer/HComProp/Label.text = str(Econ.HEAVY_COM_PROPERTY_RATE).pad_decimals(2)
	$CenterContainer/VBoxContainer/HComInc/Label.text = str(Econ.HEAVY_COM_INCOME_RATE).pad_decimals(2)
	
