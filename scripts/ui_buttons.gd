extends Control

export(ButtonGroup) var group

var mapName
var mapPath
var savePopup
var loadPopup

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in group.get_buttons():
		i.connect("pressed", self, "button_pressed")
		i.connect("mouse_entered", self, "button_hover", [i])
		i.connect("mouse_exited", self, "button_exit")

func button_exit():
	get_node("../BottomBar/HoverText").text = ""

# Displays detailed tool information when hovering
func button_hover(button):
	var toolInfo = get_node("../BottomBar/HoverText")

	match button.get_name():
		'increase_tax_button':
			toolInfo.text = "Increase city tax rate by 1%"
		'decrease_tax_button':
			toolInfo.text = "Decrease city tax rate by 1%"
		'dirt_button':
			toolInfo.text = "Replace base tile with dirt / Raise dirt base tile height   (Right Click: Lower dirt base tile height)"
		'rock_button':
			toolInfo.text = "Replace base tile with rock / Raise rock base tile height   (Right Click: Lower rock base tile height)"
		'sand_button':
			toolInfo.text = "Replace base tile with sand / Raise and base tile height   (Right Click: Lower sand base tile height)"
		'ocean_button':
			toolInfo.text = "Replace base tile with ocean"
		'lt_res_zone_button':
			toolInfo.text = "Light Residential Zone   (Right Click: Remove zoning)"
		'hv_res_zone_button':
			toolInfo.text = "Heavy Residential Zone   (Right Click: Remove zoning)"
		'add_house_button':
			toolInfo.text = "Add building to residential zone   (Right Click: Remove building)"
		'add_resident_button':
			toolInfo.text = "Add resident to residential zone   (Right Click: Remove person)"
		'lt_com_zone_button':
			toolInfo.text = "Light Commercial Zone   (Right Click: Remove zoning)"
		'hv_com_zone_button':
			toolInfo.text = "Heavy Commercial Zone   (Right Click: Remove zoning)"
		'add_building_button':
			toolInfo.text = "Add building to commercial zone   (Right Click: Remove building)"
		'add_employee_button':
			toolInfo.text = "Add employee to commercial zone   (Right Click: Remove employee)"
		'power_plant_button':
			toolInfo.text = "Build Power Plant"
		'road_button':
			toolInfo.text = "Built infrastructure (road/power/water) tile   (Right Click: Remove infrastructure)"
		'park_button':
			toolInfo.text = "Built Park   (Right Click: Remove park)"	
		'beach_rocks_button':
			toolInfo.text = "Add beach rocks to sand tile   (Right Click: Remove rocks)"
		'beach_grass_button':
			toolInfo.text = "Add beach grass to sand tile   (Right Click: Remove rocks)"			
		'clear_button':
			toolInfo.text = "Clear tile"
		'repair_button':
			toolInfo.text = "Repair damaged tiles"
		'add_water_button':
			toolInfo.text = "Increase tile water height  (Right Click: Lower tile water height)"
		'clear_water_button':
			toolInfo.text = "Remove all water from tile"
		'raise_ocean_button':
			toolInfo.text = "Increase the height of the ocean"
		'lower_ocean_button':
			toolInfo.text = "Decrease the height of the ocean"
		'damage_button':
			toolInfo.text = "Evaluate current flooding and erosion damage from ocean"
		'satisfaction_button':
			toolInfo.text = "Evaluate current resident city satisfaction"
		'rotate_camera_button':
			toolInfo.text = "Rotate camera 1/4 turn"
		'quicksave_button':
			toolInfo.text = "Quicksave current map"

func button_pressed():
	var mapNode = get_node("../../")
	
	match group.get_pressed_button().get_name():
		'increase_tax_button':
			Econ.adjust_tax_rate(0.01)
			#City.extend_map()
			#mapNode.initCamera()
		'decrease_tax_button':
			Econ.adjust_tax_rate(-0.01)
			#City.reduce_map()
			#mapNode.initCamera()
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
		'power_plant_button':
			Global.mapTool = Global.Tool.INF_POWER_PLANT
		'park_button':
			Global.mapTool = Global.Tool.INF_PARK
		'road_button':
			Global.mapTool = Global.Tool.INF_ROAD
		'beach_rocks_button':
			Global.mapTool = Global.Tool.INF_BEACH_ROCKS
		'beach_grass_button':
			Global.mapTool = Global.Tool.INF_BEACH_GRASS
		'clear_button':
			Global.mapTool = Global.Tool.CLEAR_TILE
		'repair_button':
			Global.mapTool = Global.Tool.REPAIR
		'add_water_button':
			Global.mapTool = Global.Tool.LAYER_WATER
		'clear_water_button':
			Global.mapTool = Global.Tool.CLEAR_WATER
		
		'raise_ocean_button':
			Global.mapTool = Global.Tool.NONE
			if Global.oceanHeight < Global.MAX_HEIGHT:
				Global.oceanHeight += 1
				City.updateOceanHeight(1)
				get_node("../TopBar/ActionText").text = "Ocean height raised to %s" % [Global.oceanHeight]
		
		'lower_ocean_button':
			Global.mapTool = Global.Tool.NONE
			if Global.oceanHeight > 0:
				Global.oceanHeight -= 1
				City.updateOceanHeight(-1)
				get_node("../TopBar/ActionText").text = "Ocean height lowered to %s" % [Global.oceanHeight]
		
		'damage_button':
			Global.mapTool = Global.Tool.NONE
			City.calculate_damage()
		
		'satisfaction_button':
			Global.mapTool = Global.Tool.NONE
			City.calculate_satisfaction()
			get_node("../TopBar/ActionText").text = "Flooding damage calculated"
		
		'quicksave_button':
			Global.mapTool = Global.Tool.NONE
			if not Global.mapPath.empty():
				SaveLoad.saveMapData(Global.mapPath)
				get_node("../TopBar/ActionText").text = "Map data saved"
			else:
				OS.alert('There is no existing save file to quicksave to, please use the Save button to make a new save file.', 'No Save File')
		
		'rotate_camera_button':
			Global.mapTool = Global.Tool.NONE
			get_node("../../Camera2D").rotateCamera(1)
			get_node("../../VectorMap").rotate_map()

		'zoom_out_button':
			get_node("../../Camera2D").zoom_out()
			Global.mapTool = Global.Tool.NONE
		
		'zoom_in_button':
			print("ZOOMIN")
			get_node("../../Camera2D").zoom_in()
			Global.mapTool = Global.Tool.NONE
		# 'save_button':
		# 	print("SAVE")
		# 	Global.mapTool = Global.Tool.NONE
		# 	savePopup.popup_centered()
		# 'load_button':
		# 	Global.mapTool = Global.Tool.NONE
		# 	loadPopup.popup_centered()
		# 'exit_button':
		# 	Global.mapTool = Global.Tool.NONE
		# 	get_tree().quit()
