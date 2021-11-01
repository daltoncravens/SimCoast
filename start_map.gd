extends Node2D

const MAP_EDGE_BUFFER = 150
const TILES_IN_SET = 11
const DIRT_TILE_START = 0
const SAND_TILE_START = 11
const WATER_TILE_START = 22
const RZONE_TILE_START = 0
const CZONE_TILE_START = 11
const IZONE_TILE_START = 22
const PARK_TILE_START = 0
const ROAD_TILE_START = 11

var mapPath = "res://maps/test.json"
var elementTileMap
var zoningTileMap
var unitTileMap
var oceanTileMap
var vectorMap
var camera

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_node("Camera2D")
	elementTileMap = get_node("Base")
	initCamera(Global.mapWidth, Global.mapHeight)

# Set camera to start at middle of map, and set camera edge limits
# Width/height is number of map tiles
func initCamera(width, height):
	var mid_x = (width / 2) * Global.TILE_WIDTH
	var mid_y = (height / 2) * Global.TILE_HEIGHT
	
	# Use the player starting tile to calculate camera position
	camera.position.y = mid_y
	
	camera.limit_left = (mid_x * -1) - MAP_EDGE_BUFFER
	camera.limit_top = -MAP_EDGE_BUFFER
	camera.limit_right = mid_x + MAP_EDGE_BUFFER
	camera.limit_bottom = Global.mapHeight * Global.TILE_HEIGHT + MAP_EDGE_BUFFER

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
				if !Global.tileMap[cube.i][cube.j].is_water():
					Global.tileMap[cube.i][cube.j].set_base("WATER")
				else:
					adjust_tile_height(cube)
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

	elif event is InputEventMouseMotion:		
		var tile = elementTileMap.world_to_map(get_global_mouse_position())
		var height = 0
		if !tile_out_of_bounds(tile):
			height = Global.tileMap[tile.x][tile.y].height
		
		$HUD.update_tile_display(tile, height)
		$HUD.update_mouse(get_global_mouse_position())

func tile_out_of_bounds(tile):
	return tile.x < 0 || Global.mapWidth <= tile.x || tile.y < 0 || Global.mapHeight <= tile.y
	
# Changes a tile's height depending on type of click
func adjust_tile_height(cube):	
	if Input.is_action_pressed("left_click"):
		Global.tileMap[cube.i][cube.j].raise_tile()
	elif Input.is_action_pressed("right_click"):
		Global.tileMap[cube.i][cube.j].lower_tile()

# On a change in ocean height, check each cube for a change, then re-draw
func updateOceanLevel():
	$HUD.update_ocean_display()
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			Global.tileMap[i][j].water_cube.update_polygons()

func loadMapData():
	var file = File.new()
	if not file.file_exists(mapPath):
		return
	file.open(mapPath, File.READ)
	var mapData = parse_json(file.get_as_text())
	file.close()

	elementTileMap.setGridSize(mapData.width, mapData.height)
	elementTileMap.setCells(mapData.tiles)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
