extends Node2D

# var mapName	# Custom name of map # File name for quick savings/loading
var currMapPath # Current file path of the map loaded
var copyTile				# Stores tile to use when copy/pasting tiles on the map
var tickDelay = Global.TICK_DELAY #time in seconds between ticks
var numTicks = 0 #time elapsed since start
var isPaused = false
var isFastFWD = false

# Called when the node enters the scene tree for the first time.
func _ready():
	initCamera()
	initSave_Exit()
	loadMapData("res://saves/default.json")
	$HUD/TopBar/HBoxContainer/Money.text = "Player Money: $" + Econ.comma_values(str(Econ.money))
	$HUD/TopBar/HBoxContainer/City_Income.text = "City's Net Profit: $" + Econ.comma_values(str(Econ.city_income))
	$HUD/TopBar/HBoxContainer/City_Tax_Rate.text = "Tax Rate: " + str(Econ.city_tax_rate * 100) + "%"
	$HUD/TopBar/HBoxContainer/Population.text = "Total Population: " + str(UpdatePopulation.get_population())
	$HUD/TopBar/HBoxContainer/Demand.text = "Residential Demand: " + str(UpdateDemand.calcResidentialDemand()) + "/10" + " Commercial Demand: " + str(UpdateDemand.calcCommercialDemand()) + "/10"
	$HUD/Date/Year.text = str(UpdateDate.year)
	$HUD/Date/Month.text = UpdateDate.Months.keys()[UpdateDate.month]
	

func initSave_Exit():
	$HUD/ToolMenu/VBoxContainer/VBoxContainer/save_button.connect("pressed", self, "_on_SaveButton_pressed")
	$HUD/ToolMenu/VBoxContainer/VBoxContainer/load_button.connect("pressed", self, "_on_LoadButton_pressed")
	$Popups/SaveDialog.connect("file_selected", self, "_on_file_selected_save")
	$Popups/LoadDialog.connect("file_selected", self, "_on_file_selected_load")
	$HUD/ToolMenu/VBoxContainer/VBoxContainer/exit_button.connect("pressed", self, "_on_ExitButton_pressed")

# Set camera to start at middle of map, and set camera edge limits
# Width/height is number of map tiles
func initCamera():
	var mid_x = (Global.mapWidth / 2) * Global.TILE_WIDTH
	var mid_y = (Global.mapHeight / 2) * Global.TILE_HEIGHT
	
	# Use the player starting tile to calculate camera position
	$Camera2D.position.y = mid_y
	
	$Camera2D.limit_left = (mid_x * -1) - Global.MAP_EDGE_BUFFER
	$Camera2D.limit_top = -Global.MAP_EDGE_BUFFER
	$Camera2D.limit_right = mid_x + Global.MAP_EDGE_BUFFER
	$Camera2D.limit_bottom = Global.mapHeight * Global.TILE_HEIGHT + Global.MAP_EDGE_BUFFER

# Handle inputs (clicks, keys)
func _unhandled_input(event):
	var actionText = get_node("HUD/TopBar/ActionText")
	
	if event is InputEventMouseButton and event.pressed:
		actionText.text = ""
		
		var cube = $VectorMap.get_tile_at(get_global_mouse_position())
		var tile
	
		# If the click was not on a valid tile, do nothing
		if not cube:
			return
		else:
			tile = Global.tileMap[cube.i][cube.j]
		
		# Perform action based on current tool selected
		match Global.mapTool:
			# Change Base or (if same base) raise/lower tile height
			Global.Tool.BASE_DIRT:
				if tile.get_base() != Tile.TileBase.DIRT:
					tile.set_base(Tile.TileBase.DIRT)
				else:
					City.adjust_tile_height(tile)
				
			Global.Tool.BASE_ROCK:
				if tile.get_base() != Tile.TileBase.ROCK:
					tile.set_base(Tile.TileBase.ROCK)
				else:
					City.adjust_tile_height(tile)

			Global.Tool.BASE_SAND:
				if tile.get_base() != Tile.TileBase.SAND:
					tile.set_base(Tile.TileBase.SAND)
				else:
					City.adjust_tile_height(tile)
			
			Global.Tool.BASE_OCEAN:
				if tile.get_base() != Tile.TileBase.OCEAN:
					tile.set_base(Tile.TileBase.OCEAN)
					tile.set_base_height(Global.oceanHeight)
					tile.set_water_height(0)
	
			# Clear and zone a tile (if it is not already of the same zone)
			Global.Tool.ZONE_LT_RES, Global.Tool.ZONE_HV_RES, Global.Tool.ZONE_LT_COM, Global.Tool.ZONE_HV_COM:
				if !tile.can_zone():
					return

				if Input.is_action_pressed("left_click"):
					match Global.mapTool:
						Global.Tool.ZONE_LT_RES:
							if tile.get_zone() != Tile.TileZone.LIGHT_RESIDENTIAL:
								tile.clear_tile()
								tile.set_zone(Tile.TileZone.LIGHT_RESIDENTIAL)
						Global.Tool.ZONE_HV_RES:
							if tile.get_zone() != Tile.TileZone.HEAVY_RESIDENTIAL:
								tile.clear_tile()
								tile.set_zone(Tile.TileZone.HEAVY_RESIDENTIAL)
						Global.Tool.ZONE_LT_COM:
							if tile.get_zone() != Tile.TileZone.LIGHT_COMMERCIAL:
								tile.clear_tile()
								tile.set_zone(Tile.TileZone.LIGHT_COMMERCIAL)
						Global.Tool.ZONE_HV_COM:
							if tile.get_zone() != Tile.TileZone.HEAVY_COMMERCIAL:
								tile.clear_tile()
								tile.set_zone(Tile.TileZone.HEAVY_COMMERCIAL)
								
				elif Input.is_action_pressed("right_click"):	
					tile.clear_tile()					

			# Add/Remove Buildings
			Global.Tool.ADD_RES_BLDG:
				if tile.get_zone() == Tile.TileZone.LIGHT_RESIDENTIAL || tile.get_zone() == Tile.TileZone.HEAVY_RESIDENTIAL:
					City.adjust_building_number(tile)

			Global.Tool.ADD_COM_BLDG:
				if tile.get_zone() == Tile.TileZone.LIGHT_COMMERCIAL || tile.get_zone() == Tile.TileZone.HEAVY_COMMERCIAL:
					City.adjust_building_number(tile)

			# Add/Remove People
			Global.Tool.ADD_RES_PERSON:
				if tile.is_residential():
					var change = tile.add_people(1)
					UpdatePopulation.RESIDENTS += change
					UpdatePopulation.TOTAL_POPULATION += change

			Global.Tool.ADD_COM_PERSON:
				if tile.is_commercial() && UpdatePopulation.RESIDENTS * UpdatePopulation.BASE_EMPLOYMENT_RATE > UpdatePopulation.WORKERS:
					var change = tile.add_people(1)
					UpdatePopulation.WORKERS += change

			# Water Tool
			Global.Tool.LAYER_WATER:
				if tile.get_base() != Tile.TileBase.OCEAN:
					City.adjust_tile_water(tile)
			
			Global.Tool.CLEAR_WATER:	
				tile.waterHeight = 0
				#tile.cube.update()
					
			Global.Tool.CLEAR_TILE:
				tile.clear_tile()
				
			Global.Tool.INF_POWER_PLANT:
				if Input.is_action_pressed("left_click"):
					if ((tile.get_base() == Tile.TileBase.DIRT || tile.get_base() == Tile.TileBase.ROCK) && tile.inf != Tile.TileInf.POWER_PLANT):
						if (Econ.purchase_structure(Econ.POWER_PLANT_COST)):
							tile.clear_tile()
							tile.inf = Tile.TileInf.POWER_PLANT
							City.connectPower()
							City.numPowerPlants += 1
						else:
							actionText.text = "Not enough funds!"
					elif (tile.inf == Tile.TileInf.POWER_PLANT):
						actionText.text = "Cannot build here!"
				elif Input.is_action_pressed("right_click"):
					if tile.inf == Tile.TileInf.POWER_PLANT:
						tile.clear_tile()
						City.connectPower()
						City.numPowerPlants -= 1
						
			Global.Tool.INF_PARK:
				if Input.is_action_pressed("left_click"):
					if (tile.get_base() == Tile.TileBase.DIRT && tile.inf != Tile.TileInf.PARK):
						if (Econ.purchase_structure(Econ.PARK_COST)):
							tile.clear_tile()
							tile.inf = Tile.TileInf.PARK
							City.numParks += 1
						else:
							actionText.text = "Not enough funds!"
					elif (tile.inf == Tile.TileInf.PARK):
						actionText.text = "Cannot build here!"
					else:
						actionText.text = "Park must be built on a dirt base!"
				elif Input.is_action_pressed("right_click"):
					if tile.inf == Tile.TileInf.PARK:
						tile.clear_tile()
						City.numParks -= 1
			
			Global.Tool.INF_ROAD:
				if Input.is_action_pressed("left_click"):
					if ((tile.get_base() == Tile.TileBase.DIRT || tile.get_base() == Tile.TileBase.ROCK) && tile.inf != Tile.TileInf.ROAD):
						if (Econ.purchase_structure(Econ.ROAD_COST)):
							tile.clear_tile()
							tile.inf = Tile.TileInf.ROAD
							City.connectRoads(tile)
							City.connectPower()
							City.numRoads += 1
						else:
							actionText.text = "Not enough funds!"
					elif (tile.inf == Tile.TileInf.ROAD):
						actionText.text = "Cannot build here!"
					else:
						actionText.text = "Road not buildable on tile base type"
				elif Input.is_action_pressed("right_click"):
					if tile.inf == Tile.TileInf.ROAD:
						tile.clear_tile()
						City.connectRoads(tile)
						City.connectPower()
						City.numRoads -= 1

			Global.Tool.INF_BEACH_ROCKS:
				if tile.get_base() == Tile.TileBase.SAND:
					tile.clear_tile()
					tile.inf = Tile.TileInf.BEACH_ROCKS

			Global.Tool.INF_BEACH_GRASS:
				if tile.get_base() == Tile.TileBase.SAND:
					tile.clear_tile()
					tile.inf = Tile.TileInf.BEACH_GRASS

			Global.Tool.REPAIR:
				if tile.waterHeight > 0:
					actionText.text = "Cannot repair flooded tiles. Remove water first."
				else:
					tile.tileDamage = 0
					tile.data[4] = 0

			Global.Tool.COPY_TILE:
				copyTile = tile
				actionText.text = "Tile copy saved"
				Global.mapTool = Global.Tool.NONE
				
			Global.Tool.PASTE_TILE:
				tile.paste_tile(copyTile)
				
		# Refresh graphics for cube and status bar text
		#cube.update()
		$HUD.update_tile_display(cube.i, cube.j)

	elif event is InputEventKey && event.pressed:
		if event.scancode == KEY_S:
			$Popups/SaveDialog.popup_centered()
		elif event.scancode == KEY_L:
			$Popups/LoadDialog.popup_centered()
		elif event.scancode == KEY_Z:
			actionText.text = "Flood and erosion damange calculated"
			City.calculate_damage()
		elif event.scancode == KEY_P:
			actionText.text = "Power grid recalculated"
			City.connectPower()
		elif event.scancode == KEY_C:
			actionText.text = "Select tile to copy"
			Global.mapTool = Global.Tool.COPY_TILE
		elif event.scancode == KEY_V:
			actionText.text = "Paste tool selected"
			Global.mapTool = Global.Tool.PASTE_TILE

	elif event is InputEventMouseMotion:		
		var cube = $VectorMap.get_tile_at(get_global_mouse_position())
		
		if cube:
			$HUD.update_tile_display(cube.i, cube.j)
		else:
			get_node("HUD/BottomBar/HoverText").text = ""

# Saves global variables and map data to a JSON file
func saveMapData(mapPath):
	var pathValues = SaveLoad.saveData(mapPath) 
	var correctMapName = pathValues[0]
	currMapPath = pathValues[1]
	get_node("HUD/TopBar/ActionText").text = "Map file '%s'.json saved" % [correctMapName]

func loadMapData(mapPath):
	# var file = File.new()
	# print(mapPath)
	# if not file.file_exists(mapPath):
	# 	get_node("HUD/TopBar/ActionText").text = "Error: Unable to find map file '%s'.json" % ["mapName"]
	# 	return
	# file.open(mapPath, File.READ)
	# var mapData = parse_json(file.get_as_text())
	# file.close()
	
	# Global.mapWidth = mapData.mapWidth
	# Global.mapHeight = mapData.mapHeight
	# Global.oceanHeight = mapData.oceanHeight
	# Global.seaLevel = mapData.seaLevel
	
	# Global.tileMap.clear()
	
	# for _x in range(Global.mapWidth):
	# 	var row = []
	# 	row.resize(Global.mapHeight)
	# 	Global.tileMap.append(row)

	# for tileData in mapData.tiles:
	# 	Global.tileMap[tileData[0]][tileData[1]] = Tile.new(int(tileData[0]), int(tileData[1]), int(tileData[2]), int(tileData[3]), int(tileData[4]), int(tileData[5]), int(tileData[6]), tileData[7])
	var mapName = SaveLoad.loadData(mapPath)
	$VectorMap.loadMap()
	get_node("HUD/TopBar/ActionText").text = "Map file '%s'.json loaded" % [mapName]
	City.connectPower()


func _on_SaveButton_pressed():
	$Popups/SaveDialog.popup_centered()

func _on_LoadButton_pressed():
	$Popups/LoadDialog.popup_centered()

func _on_file_selected_load(filePath):
	if ".json" in filePath:
		loadMapData(filePath)
		initCamera()
		print("File Selected: ", filePath)
	else:
		OS.alert('File chosen is of wrong type, the game specifically uses JSON files.', 'Warning')

func _on_file_selected_save(filePath):
	print("File Selected: ", filePath)
	saveMapData(filePath)
	$HUD/TopBar/ActionText.text = "Map Data Saved"

func _on_ExitButton_pressed():
	get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !isPaused:
		tickDelay -= delta
		if tickDelay <= 0:
			
			numTicks += 1
			#print("Ticks since start: " + str(ticksSinceStart))
			
			# print("Updating on tick: " + str(numTicks))
			update_game_state()
			update_graphics()
			if isFastFWD:
				tickDelay = Global.TICK_DELAY * 0.5
			else:
				tickDelay = Global.TICK_DELAY

func update_game_state():
	#print("Updating game state on tick: " + str(numTicks))
	UpdateWaves.update_waves()
	City.calculate_damage()
	UpdateValue.update_land_value()
	UpdateHappiness.update_happiness()
	UpdatePopulation.update_population()
	UpdateDemand.get_demand()
	Econ.calcCityIncome()
	Econ.calculate_upkeep_costs()
	UpdateDate.update_date()
	
func update_graphics():
	#print("Updating graphics on tick: " + str(numTicks))
	UpdateGraphics.update_graphics()
	Econ.updateProfitDisplay()

func _on_play_button_toggled(button_pressed:bool):
	isPaused = button_pressed

func _on_fastfwd_button_toggled(button_pressed:bool):
	isFastFWD = button_pressed
