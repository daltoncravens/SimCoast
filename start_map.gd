# To Do
# - Fix time overflow value
# - Change time to be month per turn (rather than day)
# - Update ocean height method
# - Create a storm method to:
#   - Raise a storm surge
#   - Calculate damage and erosion for each square
#   - Restore ocean level with updated information for each square
# - Create a way to call storm (flood next month, restore month after)


extends Node2D

var mapName = "test1"
var vectorMap
var camera

var gameTime = {"month": 1, "day": 1, "year": 2000}
var gameTime_since_update = 0.0

var gameSpeed = 10000
var gamePaused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_node("Camera2D")
	initCamera(Global.mapWidth, Global.mapHeight)

# Set camera to start at middle of map, and set camera edge limits
# Width/height is number of map tiles
func initCamera(width, height):
	var mid_x = (width / 2) * Global.TILE_WIDTH
	var mid_y = (height / 2) * Global.TILE_HEIGHT
	
	# Use the player starting tile to calculate camera position
	camera.position.y = mid_y
	
	camera.limit_left = (mid_x * -1) - Global.MAP_EDGE_BUFFER
	camera.limit_top = -Global.MAP_EDGE_BUFFER
	camera.limit_right = mid_x + Global.MAP_EDGE_BUFFER
	camera.limit_bottom = Global.mapHeight * Global.TILE_HEIGHT + Global.MAP_EDGE_BUFFER

# Handle inputs (clicks, keys)
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
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
			
			Global.Tool.INF_PARK:
				if tile.get_base() == Tile.TileBase.DIRT:
					tile.clear_tile()
					tile.inf = Tile.TileInf.PARK
			
		# Refresh graphics for cube and status bar text
		cube.update()
		$HUD.update_tile_display(cube.i, cube.j, Global.tileMap[cube.i][cube.j].baseHeight, Global.tileMap[cube.i][cube.j].waterHeight)

	elif event is InputEventKey && event.pressed:
		if event.scancode == KEY_O and Global.oceanHeight > 0:
			Global.oceanHeight -= 1
			updateOceanHeight(-1)
		elif event.scancode == KEY_P and Global.oceanHeight < Global.MAX_HEIGHT:
			Global.oceanHeight += 1
			updateOceanHeight(1)
		elif event.scancode == KEY_Q:
			camera.rotateCamera(-1)
			$VectorMap.rotate_map()
		elif event.scancode == KEY_W:
			camera.rotateCamera(1)
			$VectorMap.rotate_map()
		elif event.scancode == KEY_S:
			saveMapData()
			print("Map Data Saved")
		elif event.scancode == KEY_L:
			loadMapData()
			print("Loading map data...")
		elif event.scancode == KEY_SPACE:
			if gamePaused:
				print("Resuming game")
			else:
				print("Pausing game")
			gamePaused = !gamePaused
		elif event.scancode == KEY_1:
			print("Game Speed: Slow")
			gameSpeed = 5000
		elif event.scancode == KEY_2:
			print("Game Speed: Normel")
			gameSpeed = 20000
		elif event.scancode == KEY_3:
			print("Game Speed: Fast")
			gameSpeed = 60000

	elif event is InputEventMouseMotion:		
		var cube = $VectorMap.get_tile_at(get_global_mouse_position())
		
		if cube:
			$HUD.update_tile_display(cube.i, cube.j, Global.tileMap[cube.i][cube.j].baseHeight, Global.tileMap[cube.i][cube.j].waterHeight)
		else:
			$HUD.update_tile_display('', '', '', '')
	
		$HUD.update_mouse(get_global_mouse_position())

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

# Called whenever there is a visual change in ocean level
func updateOceanHeight(dir):
	# Update value in display
	$HUD.update_ocean_display()
	
	# Keeps track of which map tiles have been checked
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
				Global.tileMap[i][j].cube.update_polygons()
				Global.tileMap[i][j].cube.update()
				visited[i][j] = 1
				queue.append(Global.tileMap[i][j])

	# For each tile in queue, adjust water height, then check if neighbors should be added to queue
	while !queue.empty():
		var tile = queue.pop_front()

		# Adjust water height to match ocean height
		if !tile.is_ocean():
			tile.waterHeight = Global.oceanHeight - tile.baseHeight
			Global.tileMap[tile.i][tile.j].cube.update_polygons()
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

func tile_out_of_bounds(cube):
	return cube.i < 0 || Global.mapWidth <= cube.i || cube.j < 0 || Global.mapHeight <= cube.j
			
func is_tile_inbounds(i, j):
	if i < 0 || Global.mapWidth <= i:
		return false
	
	if j < 0 || Global.mapHeight <= j:
		return false
	
	return true

func saveMapData():
	var filePath = str("res://maps/", mapName, ".json")
	
	var tileData = []
			
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			tileData.append([i, j, Global.tileMap[i][j].baseHeight, Global.tileMap[i][j].waterHeight, Global.tileMap[i][j].base, Global.tileMap[i][j].zone, Global.tileMap[i][j].inf])
			
	var data = {
		"name": mapName,
		"mapWidth": Global.mapWidth,
		"mapHeight": Global.mapHeight,
		"oceanHeight": Global.oceanHeight,
		"date": gameTime,
		"tiles": tileData
	}
	
	var file
	file = File.new()
	file.open(filePath, File.WRITE)
	file.store_line(to_json(data))
	file.close()

func updateGameTime(delta):
	gameTime_since_update += delta * gameSpeed

	while gameTime_since_update > 60000:
		if gameTime.month == 1 || gameTime.month == 3 || gameTime.month == 5 || gameTime.month == 7 || gameTime.month == 8 || gameTime.month == 10 || gameTime.month == 12:
			if gameTime.day < 31:
				gameTime.day += 1
			else:
				gameTime.day = 1
				if gameTime.month < 12:
					gameTime.month += 1
				else:
					gameTime.month = 1
					gameTime.year += 1
		elif gameTime.month == 2:
			if gameTime.year % 4 == 0:
				if gameTime.day < 29:
					gameTime.day += 1
				else:
					gameTime.day = 1
					gameTime.month += 1
			else:
				if gameTime.day < 28:
					gameTime.day += 1
				else:
					gameTime.day = 1
					gameTime.month += 1
		else:
			if gameTime.day < 30:
				gameTime.day += 1
			else:
				gameTime.day = 1
				gameTime.month += 1
		
		gameTime_since_update -= 60000
		
	$HUD.update_time(gameTime)

func loadMapData():
	var file = File.new()
	var filePath = str("res://maps/", mapName, ".json")
		
	if not file.file_exists(filePath):
		print("Error: Unable to find map file")
		return
	file.open(filePath, File.READ)
	var mapData = parse_json(file.get_as_text())
	file.close()
	
	Global.mapWidth = mapData.mapWidth
	Global.mapHeight = mapData.mapHeight
	Global.oceanHeight = mapData.oceanHeight
	gameTime = mapData.date
		
	Global.tileMap.clear()
	
	for _x in range(Global.mapWidth):
		var row = []
		row.resize(Global.mapHeight)
		Global.tileMap.append(row)

	for tileData in mapData.tiles:
		Global.tileMap[tileData[0]][tileData[1]] = Tile.new(int(tileData[0]), int(tileData[1]), int(tileData[2]), int(tileData[3]), int(tileData[4]), int(tileData[5]), int(tileData[6]))

	$VectorMap.loadMap()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !gamePaused:
		updateGameTime(_delta)
