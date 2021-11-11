extends Node2D

var mapPath = "res://maps/test.json"
var vectorMap
var camera

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
	
		# If the click was not on a valid tile, do nothing
		if not cube:
			return
		
		# Perform action based on current tool selected
		match Global.mapTool:
			1: # Dirt Base Tool
				if !Global.tileMap[cube.i][cube.j].is_dirt():
					Global.tileMap[cube.i][cube.j].set_base("DIRT")
				else:
					adjust_tile_height(cube)
				cube.update()
			2: # Sand Base Tool
				if !Global.tileMap[cube.i][cube.j].is_sand():
					Global.tileMap[cube.i][cube.j].set_base("SAND")
				else:
					adjust_tile_height(cube)
				cube.update()
			3: # Water Base Tool
				#if !Global.tileMap[cube.i][cube.j].is_water():
				#	Global.tileMap[cube.i][cube.j].set_base("WATER")
				#else:
				adjust_tile_water(cube)
				cube.update()
			# Zoning and Infrasturcture
			4, 5, 6, 7, 8:
				if !Global.tileMap[cube.i][cube.j].is_dirt():
					return

				Global.tileMap[cube.i][cube.j].clear_tile()
				
				if Input.is_action_pressed("left_click"):
					match Global.mapTool:
						4:
							Global.tileMap[cube.i][cube.j].zone = 1
						5:
							Global.tileMap[cube.i][cube.j].zone = 2
						6:
							Global.tileMap[cube.i][cube.j].zone = 3
						7:
							Global.tileMap[cube.i][cube.j].inf = 2
						8:
							Global.tileMap[cube.i][cube.j].inf = 1
			
				cube.update()

	elif event is InputEventKey && event.pressed:
		if event.scancode == KEY_O and Global.oceanLevel > 0:
			Global.oceanLevel -= 1
			updateOceanLevel()
		elif event.scancode == KEY_P and Global.oceanLevel < 9:
			Global.oceanLevel += 1
			updateOceanLevel()
		elif event.scancode == KEY_Q:
			camera.rotateCamera(-1)
			$VectorMap.rotate_map()
		elif event.scancode == KEY_W:
			camera.rotateCamera(1)
			$VectorMap.rotate_map()

	elif event is InputEventMouseMotion:		
		var cube = $VectorMap.get_tile_at(get_global_mouse_position())
		
		if cube:
			$HUD.update_tile_display(cube.i, cube.j, Global.tileMap[cube.i][cube.j].height, Global.tileMap[cube.i][cube.j].waterHeight)
		else:
			$HUD.update_tile_display('x', 'x', 'x', 'x')
	
		$HUD.update_mouse(get_global_mouse_position())

func tile_out_of_bounds(cube):
	return cube.i < 0 || Global.mapWidth <= cube.i || cube.j < 0 || Global.mapHeight <= cube.j
	
# Changes a tile's height depending on type of click
func adjust_tile_height(cube):	
	if Input.is_action_pressed("left_click"):
		Global.tileMap[cube.i][cube.j].raise_tile()
	elif Input.is_action_pressed("right_click"):
		Global.tileMap[cube.i][cube.j].lower_tile()

# Change water height of tile
func adjust_tile_water(cube):
	if Input.is_action_pressed("left_click"):
		Global.tileMap[cube.i][cube.j].raise_water()
	elif Input.is_action_just_pressed("right_click"):
		Global.tileMap[cube.i][cube.j].lower_water()

# On a change in ocean height, check each cube for a change, then re-draw
func updateOceanLevel():
	$HUD.update_ocean_display()
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			Global.tileMap[i][j].water_cube.update_polygons()

#func loadMapData():
#	var file = File.new()
#	if not file.file_exists(mapPath):
#		return
#	file.open(mapPath, File.READ)
#	var mapData = parse_json(file.get_as_text())
#	file.close()
#
#	elementTileMap.setGridSize(mapData.width, mapData.height)
#	elementTileMap.setCells(mapData.tiles)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
