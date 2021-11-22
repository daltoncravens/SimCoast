extends Control

export(ButtonGroup) var group

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in group.get_buttons():
		i.connect("pressed", self, "button_pressed")

func button_pressed():
	match group.get_pressed_button().get_name():
		'dirt_button':
			Global.mapTool = Global.Tool.BASE_DIRT
		'rock_button':
			Global.mapTool = Global.Tool.BASE_ROCK
		'sand_button':
			Global.mapTool = Global.Tool.BASE_SAND
		'ocean_button':
			Global.mapTool = Global.Tool.BASE_OCEAN
		'lt_res_zone_button':
			Global.mapTool = Global.Tool.ZONE_LT_RES
		'hv_res_zone_button':
			Global.mapTool = Global.Tool.ZONE_HV_RES
		'add_house_button':
			Global.mapTool = Global.Tool.ADD_RES_BLDG
		'add_resident_button':
			Global.mapTool = Global.Tool.ADD_RES_PERSON
		'lt_com_zone_button':
			Global.mapTool = Global.Tool.ZONE_LT_COM
		'hv_com_zone_button':
			Global.mapTool = Global.Tool.ZONE_HV_COM
		'add_building_button':
			Global.mapTool = Global.Tool.ADD_COM_BLDG
		'add_employee_button':
			Global.mapTool = Global.Tool.ADD_COM_PERSON
		'park_button':
			Global.mapTool = Global.Tool.INF_PARK
		'road_button':
			Global.mapTool = Global.Tool.INF_ROAD
		'clear_button':
			Global.mapTool = Global.Tool.CLEAR
		'water_button':
			Global.mapTool = Global.Tool.LAYER_WATER
		'lower_ocean_button':
			if Global.oceanHeight > 0:
				Global.oceanHeight -= 1
				get_node("../../").updateOceanHeight(-1)
		'raise_ocean_button':
			if Global.oceanHeight < Global.MAX_HEIGHT:
				Global.oceanHeight += 1
				get_node("../../").updateOceanHeight(1)
		'rotate_camera_button':
			print("Rotate Camera")
		'quicksave_button':
			print("Quicksave")
