extends Node2D

var mapName = "test2"
var powerPlants = []   	# Keep track of power plant tiles for power distribution
var copyTile

# Called when the node enters the scene tree for the first time.
func _ready():
	initCamera()

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
					adjust_tile_height(tile)
				
			Global.Tool.BASE_ROCK:
				if tile.get_base() != Tile.TileBase.ROCK:
					tile.set_base(Tile.TileBase.ROCK)
				else:
					adjust_tile_height(tile)

			Global.Tool.BASE_SAND:
				if tile.get_base() != Tile.TileBase.SAND:
					tile.set_base(Tile.TileBase.SAND)
				else:
					adjust_tile_height(tile)
			
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
					adjust_building_number(tile)

			Global.Tool.ADD_COM_BLDG:
				if tile.get_zone() == Tile.TileZone.LIGHT_COMMERCIAL || tile.get_zone() == Tile.TileZone.HEAVY_COMMERCIAL:
					adjust_building_number(tile)

			# Add/Remove People
			Global.Tool.ADD_RES_PERSON:
				if tile.get_zone() == Tile.TileZone.LIGHT_RESIDENTIAL || tile.get_zone() == Tile.TileZone.HEAVY_RESIDENTIAL:
					adjust_people_number(tile)

			Global.Tool.ADD_COM_PERSON:
				if tile.get_zone() == Tile.TileZone.LIGHT_COMMERCIAL || tile.get_zone() == Tile.TileZone.HEAVY_COMMERCIAL:
					adjust_people_number(tile)

			# Water Tool
			Global.Tool.LAYER_WATER:
				if tile.get_base() != Tile.TileBase.OCEAN:
					adjust_tile_water(tile)
			
			Global.Tool.INF_POWER_PLANT:
				if tile.get_base() == Tile.TileBase.DIRT || tile.get_base() == Tile.TileBase.ROCK:
					tile.clear_tile()
					tile.inf = Tile.TileInf.POWER_PLANT
					Global.powerPlants.append(tile)
					connectPower()
			
			Global.Tool.INF_PARK:
				if tile.get_base() == Tile.TileBase.DIRT:
					tile.clear_tile()
					tile.inf = Tile.TileInf.PARK
				else:
					actionText.text = "Park must be built on a dirt base"
			
			Global.Tool.INF_ROAD:
				if Input.is_action_pressed("left_click"):
					if tile.get_base() == Tile.TileBase.DIRT || tile.get_base() == Tile.TileBase.ROCK:
						tile.clear_tile()
						tile.inf = Tile.TileInf.ROAD
						connectRoads(tile)
					else:
						actionText.text = "Road not buildable on tile base type"
				elif Input.is_action_pressed("right_click"):
					if tile.inf == Tile.TileInf.ROAD:
						tile.clear_tile()
						connectRoads(tile)

			Global.Tool.INF_BEACH_ROCKS:
				if tile.get_base() == Tile.TileBase.SAND:
					tile.clear_tile()
					tile.inf = Tile.TileInf.BEACH_ROCKS

			Global.Tool.INF_BEACH_GRASS:
				if tile.get_base() == Tile.TileBase.SAND:
					tile.clear_tile()
					tile.inf = Tile.TileInf.BEACH_GRASS

			Global.Tool.COPY_TILE:
				copyTile = tile
				actionText.text = "Tile copy saved"
				
			Global.Tool.PASTE_TILE:
				tile.paste_tile(copyTile)
				
		# Refresh graphics for cube and status bar text
		cube.update()
		$HUD.update_tile_display(cube.i, cube.j)

	elif event is InputEventKey && event.pressed:
		if event.scancode == KEY_S:
			saveMapData()
		elif event.scancode == KEY_L:
			loadMapData()
			initCamera()
		elif event.scancode == KEY_Z:
			actionText.text = "Flood and erosion damange calculated"
			calculate_damage()
		elif event.scancode == KEY_P:
			actionText.text = "Power grid recalculated"
			connectPower()
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

func adjust_building_number(tile):
	if Input.is_action_pressed("left_click"):
		tile.add_building()
	elif Input.is_action_pressed("right_click"):
		tile.remove_building()

func adjust_people_number(tile):
	if Input.is_action_pressed("left_click"):
		tile.add_people(1)
	elif Input.is_action_pressed("right_click"):
		tile.remove_people(1)
		
# Changes a tile's height depending on type of click
func adjust_tile_height(tile):	
	if Input.is_action_pressed("left_click"):
		tile.raise_tile()
	elif Input.is_action_pressed("right_click"):
		tile.lower_tile()

# Change water height of tile
func adjust_tile_water(tile):
	if Input.is_action_pressed("left_click"):
		tile.raise_water()
	elif Input.is_action_just_pressed("right_click"):
		tile.lower_water()

# Add a new row and column of empty tiles
func extend_map():
	if Global.mapHeight >= Global.MAX_MAP_SIZE || Global.mapWidth >= Global.MAX_MAP_SIZE:
		return
	
	var new_row = []
	new_row.resize(Global.mapWidth)
	Global.tileMap.append(new_row)

	for j in Global.mapWidth:
		Global.tileMap[Global.mapHeight][j] = Tile.new(Global.mapHeight, j, 0, 0, 0, 0, 0, [0, 0, 0, 0, 0])
		$VectorMap.add_tile(Global.mapHeight, j)
	
	Global.mapHeight += 1
		
	for i in Global.mapHeight:
		Global.tileMap[i].append(Tile.new(i, Global.mapWidth, 0, 0, 0, 0, 0, [0, 0, 0, 0, 0]))
		$VectorMap.add_tile(i, Global.mapWidth)
	
	Global.mapWidth += 1

	get_node("HUD/TopBar/ActionText").text = "Map size extended to (%s x %s)" % [Global.mapWidth, Global.mapHeight]

# Delete the last row and column of the map
func reduce_map():
	if Global.mapHeight <= Global.MIN_MAP_SIZE || Global.mapWidth <= Global.MIN_MAP_SIZE:
		return
	
	Global.mapHeight -= 1
	
	for j in Global.mapWidth:
		$VectorMap.remove_tile(Global.mapHeight, j)
	
	Global.mapWidth -= 1
	
	for i in Global.mapHeight:
		$VectorMap.remove_tile(i, Global.mapWidth)
	
	Global.tileMap.pop_back()
	
	for i in Global.tileMap.size():
		Global.tileMap[i].pop_back()
	
	get_node("HUD/TopBar/ActionText").text = "Map size reduced to (%s x %s)" % [Global.mapWidth, Global.mapHeight]

# Starting from each power plant, trace power distribution and power tiles if they are connected
func connectPower():
	# De-power every tile on the map
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			Global.tileMap[i][j].powered = false

	for plant in Global.powerPlants:
		plant.powered = true

		var queue = []
		var neighbors = [[plant.i-1, plant.j], [plant.i+1, plant.j], [plant.i, plant.j-1], [plant.i, plant.j+1]]
		
		for n in neighbors:
			if roadConnected(plant, n, Global.MAX_CONNECTION_HEIGHT):
				queue.append(Global.tileMap[n[0]][n[1]])
		
		while !queue.empty():
			var road = queue.pop_front()
			
			if !road.powered:
				road.powered = true
			
				# Check neighbors: if a zone, power it; if a connected road, add it to the queue
				neighbors = [[road.i-1, road.j], [road.i+1, road.j], [road.i, road.j-1], [road.i, road.j+1]]

				for n in neighbors:
					if is_tile_inbounds(n[0], n[1]):
						if Global.tileMap[n[0]][n[1]].inf == Tile.TileInf.ROAD:
							if roadConnected(road, n, Global.MAX_CONNECTION_HEIGHT):
								if Global.tileMap[n[0]][n[1]].powered == false:
									queue.append(Global.tileMap[n[0]][n[1]])
						elif Global.tileMap[n[0]][n[1]].is_zoned():
							Global.tileMap[n[0]][n[1]].powered = true
							Global.tileMap[n[0]][n[1]].cube.update()


# Check tile for neighboring road connections, and create connections from any connecting roads to tile
func connectRoads(tile):
	var queue = [tile]
	var neighbors = [[tile.i-1, tile.j], [tile.i+1, tile.j], [tile.i, tile.j-1], [tile.i, tile.j+1]]
	var maxHeightDiff = Global.MAX_CONNECTION_HEIGHT
	
	for n in neighbors:
		if roadConnected(tile, n, maxHeightDiff):
			queue.append(Global.tileMap[n[0]][n[1]])
	
	while !queue.empty():
		var road = queue.pop_front()
		road.data = 	[0, 0, 0, 0, 0]
		
		if roadConnected(road, [road.i-1, road.j], maxHeightDiff):
			road.data[0] = 1
		if roadConnected(road, [road.i, road.j-1], maxHeightDiff):
			road.data[1] = 1
		if roadConnected(road, [road.i+1, road.j], maxHeightDiff):
			road.data[2] = 1
		if roadConnected(road, [road.i, road.j+1], maxHeightDiff):
			road.data[3] = 1

		road.cube.update()

func roadConnected(tile, n, diff):
	if !is_tile_inbounds(n[0], n[1]):
		return false
	if Global.tileMap[n[0]][n[1]].inf != Tile.TileInf.ROAD:
		return false
	if abs(tile.get_base_height() - Global.tileMap[n[0]][n[1]].get_base_height()) > diff:
		return false
	
	return true

# Called whenever there is a visual change in ocean level
func updateOceanHeight(dir):	
	# 2D array to keep track of which map tiles have been checked
	var visited = []
	for x in range(Global.mapWidth):
		visited.append([])
		for _y in range(Global.mapHeight):
			visited[x].append(0)
			
	# Only tiles that have changes to water values are placed in queue
	var queue = []
	
	# Update all ocean tiles, adjust height, then add to queue
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			if Global.tileMap[i][j].is_ocean():
				Global.tileMap[i][j].baseHeight = Global.oceanHeight
				Global.tileMap[i][j].waterHeight = 0
				Global.tileMap[i][j].cube.update()
				visited[i][j] = 1
				queue.append(Global.tileMap[i][j])

	# For each tile in queue, adjust water height, then check if neighbors should be added to queue
	while !queue.empty():
		var tile = queue.pop_front()

		# Adjust water height to match ocean height
		if !tile.is_ocean():
			tile.waterHeight = Global.oceanHeight - tile.baseHeight
			Global.tileMap[tile.i][tile.j].cube.update()

		# Check each orthogonal neighbor to determine if it will flood
		var neighbors = [[tile.i-1, tile.j], [tile.i+1, tile.j], [tile.i, tile.j-1], [tile.i, tile.j+1]]
		for n in neighbors:
			if is_tile_inbounds(n[0], n[1]) && visited[n[0]][n[1]] == 0:
				visited[n[0]][n[1]] = 1
				
				# Rising ocean level
				if dir > 0 && Global.tileMap[n[0]][n[1]].baseHeight < Global.oceanHeight:
					queue.append(Global.tileMap[n[0]][n[1]])

				# Falling ocean level
				if dir < 1 && Global.tileMap[n[0]][n[1]].baseHeight + Global.tileMap[n[0]][n[1]].waterHeight > Global.oceanHeight:
					if Global.tileMap[n[0]][n[1]].waterHeight >= 1:
						queue.append(Global.tileMap[n[0]][n[1]])

# When flooding occurs, determine damage to infrastructure and perform tile erosion
func calculate_damage():
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			var tile = Global.tileMap[i][j]
			# If buildings present, determine damage based on water height
			if tile.get_water_height() > 0:
				if tile.has_building() && tile.is_light_zoned():
					if tile.get_water_height() <= 1:
						tile.set_damage(Tile.TileStatus.LIGHT_DAMAGE)
					elif tile.get_water_height() <= 3:
						tile.set_damage(Tile.TileStatus.MEDIUM_DAMAGE)
					else:
						tile.set_damage(Tile.TileStatus.HEAVY_DAMAGE)
				elif tile.has_building() && tile.is_heavy_zoned():
					if tile.get_water_height() <= 3:
						tile.set_damage(Tile.TileStatus.LIGHT_DAMAGE)
					elif tile.get_water_height() <= 6:
						tile.set_damage(Tile.TileStatus.MEDIUM_DAMAGE)
					else:
						tile.set_damage(Tile.TileStatus.HEAVY_DAMAGE)
				elif tile.inf == Tile.TileInf.ROAD:
					if tile.get_water_height() >= 5:
						tile.clear_tile()
				elif tile.get_base() == Tile.TileBase.SAND:
					if tile.get_water_height() >= 5:
						tile.lower_tile()
				tile.remove_water()
				tile.cube.update()

	# Restore ocean height to sea level
	Global.oceanHeight = 0
	while Global.oceanHeight < Global.seaLevel:
		Global.oceanHeight += 1
		updateOceanHeight(1)

func tile_out_of_bounds(cube):
	return cube.i < 0 || Global.mapWidth <= cube.i || cube.j < 0 || Global.mapHeight <= cube.j
			
func is_tile_inbounds(i, j):
	if i < 0 || Global.mapWidth <= i:
		return false
	
	if j < 0 || Global.mapHeight <= j:
		return false
	
	return true

# Saves global variables and map data to a JSON file
func saveMapData():
	var filePath = str("res://maps/", mapName, ".json")
	
	var tileData = []
			
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			tileData.append(Global.tileMap[i][j].get_save_tile_data())
			
	var data = {
		"name": mapName,
		"mapWidth": Global.mapWidth,
		"mapHeight": Global.mapHeight,
		"oceanHeight": Global.oceanHeight,
		"seaLevel": Global.seaLevel,
		"tiles": tileData
	}
	
	var file
	file = File.new()
	file.open(filePath, File.WRITE)
	file.store_line(to_json(data))
	file.close()
	
	get_node("HUD/TopBar/ActionText").text = "Map file '%s'.json saved" % [mapName]

func loadMapData():
	var file = File.new()
	var filePath = str("res://maps/", mapName, ".json")
		
	if not file.file_exists(filePath):
		get_node("HUD/TopBar/ActionText").text = "Error: Unable to find map file '%s'.json" % [mapName]
		return
	file.open(filePath, File.READ)
	var mapData = parse_json(file.get_as_text())
	file.close()
	
	Global.mapWidth = mapData.mapWidth
	Global.mapHeight = mapData.mapHeight
	Global.oceanHeight = mapData.oceanHeight
	Global.seaLevel = mapData.seaLevel
		
	Global.tileMap.clear()
	
	for _x in range(Global.mapWidth):
		var row = []
		row.resize(Global.mapHeight)
		Global.tileMap.append(row)

	for tileData in mapData.tiles:
		Global.tileMap[tileData[0]][tileData[1]] = Tile.new(int(tileData[0]), int(tileData[1]), int(tileData[2]), int(tileData[3]), int(tileData[4]), int(tileData[5]), int(tileData[6]), tileData[7])

	$VectorMap.loadMap()
	get_node("HUD/TopBar/ActionText").text = "Map file '%s'.json loaded" % [mapName]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
