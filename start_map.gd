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
var mapWidth = 30
var mapHeight = 30
var tileWidth = 64
var tileHeight = 32
var camera

var gameTime = {"month": 12,
				"day": 31,
				"year": 2020}
var gameTime_since_update = 0.0
var gameSpeed = 5000

# var my_x = 0
# var my_y = 0

# Called when the node enters the scene tree for the first time.

func _ready():
	Global.mapTool = 0
	camera = get_node("Camera2D")
	elementTileMap = get_node("Base")
	zoningTileMap = get_node("Base/Zoning")
	unitTileMap = get_node("Base/Units")	
	oceanTileMap = get_node("Base/Ocean")
	
	Global.oceanLevel = 2
	updateOceanLevel()
	
	initCamera(mapWidth, mapHeight)
	# loadMapData()

# Set camera to start at middle of map, and set camera edge limits
# Width/height is number of map tiles
func initCamera(width, height):
	var mid_x = (width / 2) * tileWidth
	var mid_y = (height / 2) * tileHeight
	
	# Use the player starting tile to calculate camera position
	camera.position.y = mid_y
	
	camera.limit_left = (mid_x * -1) - MAP_EDGE_BUFFER
	camera.limit_top = -MAP_EDGE_BUFFER
	camera.limit_right = mid_x + MAP_EDGE_BUFFER
	camera.limit_bottom = mapHeight * tileHeight + MAP_EDGE_BUFFER



func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var tile = elementTileMap.world_to_map(get_global_mouse_position())
		var index = elementTileMap.get_cell(tile.x, tile.y)
		var height = index % TILES_IN_SET
	
		if tile_out_of_bounds(tile):
			return
		
		match Global.mapTool:
			# Dirt Tool
			1:
				if !is_dirt(index):
					clear_tile(tile)
					elementTileMap.set_cell(tile.x, tile.y, DIRT_TILE_START + height)
				else:
					adjust_tile_height(tile, index)
			# Sand Tool
			2:
				if !is_sand(index):
					clear_tile(tile)
					elementTileMap.set_cell(tile.x, tile.y, SAND_TILE_START + height)
				else:
					adjust_tile_height(tile, index)
			# Water Tool
			3:
				if !is_water(index):
					clear_tile(tile)
					elementTileMap.set_cell(tile.x, tile.y, WATER_TILE_START + height)
				else:
					adjust_tile_height(tile, index)
			# Residential Zoning
			4:
				if !is_dirt(index):
					return
				
				if Input.is_action_pressed("left_click"):
					clear_tile(tile)
					zoningTileMap.set_cell(tile.x, tile.y, RZONE_TILE_START + height)
				elif Input.is_action_pressed("right_click"):
					zoningTileMap.set_cell(tile.x, tile.y, -1)
			# Commercial Zoning
			5:
				if !is_dirt(index):
					return
				
				if Input.is_action_pressed("left_click"):
					clear_tile(tile)
					zoningTileMap.set_cell(tile.x, tile.y, CZONE_TILE_START + height)
				elif Input.is_action_pressed("right_click"):
					zoningTileMap.set_cell(tile.x, tile.y, -1)
			# Industrial Zoning
			6:
				if !is_dirt(index):
					return
				
				if Input.is_action_pressed("left_click"):
					clear_tile(tile)
					zoningTileMap.set_cell(tile.x, tile.y, IZONE_TILE_START + height)
				elif Input.is_action_pressed("right_click"):
					zoningTileMap.set_cell(tile.x, tile.y, -1)				
			# Plant Trees
			7:
				if !is_dirt(index):
					return
				
				if Input.is_action_pressed("left_click"):
					clear_tile(tile)
					unitTileMap.set_cell(tile.x, tile.y, PARK_TILE_START + height)
				elif Input.is_action_pressed("right_click"):
					unitTileMap.set_cell(tile.x, tile.y, -1)
			# Build Road
			8:
				if !is_dirt(index):
					return
				
				if Input.is_action_pressed("left_click"):
					clear_tile(tile)
					unitTileMap.set_cell(tile.x, tile.y, ROAD_TILE_START + height)
				elif Input.is_action_pressed("right_click"):
					unitTileMap.set_cell(tile.x, tile.y, -1)

	elif event is InputEventKey && event.pressed:
		if event.scancode == KEY_O and Global.oceanLevel > 0:
			Global.oceanLevel -= 1
			updateOceanLevel()
		elif event.scancode == KEY_P and Global.oceanLevel < 9:
			Global.oceanLevel += 1
			updateOceanLevel()

	elif event is InputEventMouseMotion:
		var tile = elementTileMap.world_to_map(get_global_mouse_position())
		var height = elementTileMap.get_cell(tile.x, tile.y) % TILES_IN_SET
		
		# my_x = get_global_mouse_position().x
		# my_y = get_global_mouse_position().y
		# update()
		
		$HUD.update_tile_display(tile, height)
		$HUD.update_mouse(get_global_mouse_position())

func tile_out_of_bounds(tile):
	return tile.x < 0 || mapWidth <= tile.x || tile.y < 0 || mapHeight <= tile.y

func is_dirt(index):
	return DIRT_TILE_START <= index && index < DIRT_TILE_START + TILES_IN_SET

func is_sand(index):
	return SAND_TILE_START <= index && index < SAND_TILE_START + TILES_IN_SET

func is_water(index):
	return WATER_TILE_START <= index && index < WATER_TILE_START + TILES_IN_SET

func clear_zoning(tile):
	zoningTileMap.set_cell(tile.x, tile.y, -1)

func clear_units(tile):
	unitTileMap.set_cell(tile.x, tile.y, -1)

func clear_tile(tile):
	zoningTileMap.set_cell(tile.x, tile.y, -1)
	unitTileMap.set_cell(tile.x, tile.y, -1)

func adjust_tile_height(tile, index):
	clear_tile(tile)
	var height = index % TILES_IN_SET
	
	if Input.is_action_pressed("left_click"):
		if height < TILES_IN_SET - 1:
			elementTileMap.set_cell(tile.x, tile.y, index + 1)
			$HUD.update_tile_display(tile, height + 1)
			
	elif Input.is_action_pressed("right_click"):
		if height > 0:
			elementTileMap.set_cell(tile.x, tile.y, index - 1)
			$HUD.update_tile_display(tile, height - 1)

func updateOceanLevel():
	$HUD.update_ocean_display()
	for i in mapWidth:
		for j in mapHeight:
			var height = elementTileMap.get_cell(i, j) % TILES_IN_SET
			if height < Global.oceanLevel:
				clear_units(Vector2(i, j))
				oceanTileMap.set_cell(i, j, (height * TILES_IN_SET) + Global.oceanLevel)
			else:
				oceanTileMap.set_cell(i, j, -1)

func updateGameTime(delta):
	gameTime_since_update += delta * gameSpeed
	if gameTime_since_update > 60000:
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
		gameTime_since_update = 0
	$HUD.update_time(gameTime)

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
	updateGameTime(_delta)
