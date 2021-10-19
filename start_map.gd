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
var camera

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
	
	initCamera(Global.mapWidth, Global.mapHeight)
	# loadMapData()

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
					adjust_tile_height(tile)
					$VectorBase.redraw_map()
			# Sand Tool
			2:
				if !is_sand(index):
					clear_tile(tile)
					elementTileMap.set_cell(tile.x, tile.y, SAND_TILE_START + height)
				else:
					adjust_tile_height(tile)
			# Water Tool
			3:
				if !is_water(index):
					clear_tile(tile)
					elementTileMap.set_cell(tile.x, tile.y, WATER_TILE_START + height)
				else:
					adjust_tile_height(tile)
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
		
		$HUD.update_tile_display(tile, height)
		$HUD.update_mouse(get_global_mouse_position())

func tile_out_of_bounds(tile):
	return tile.x < 0 || Global.mapWidth <= tile.x || tile.y < 0 || Global.mapHeight <= tile.y

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

func adjust_tile_height(tile):	
	if Input.is_action_pressed("left_click"):
		Global.tileMap[tile.x][tile.y].raise_tile()	
		$VectorBase.set_shape(tile.x, tile.y)		
	elif Input.is_action_pressed("right_click"):
		Global.tileMap[tile.x][tile.y].lower_tile()
		$VectorBase.set_shape(tile.x, tile.y)		

func updateOceanLevel():
	$HUD.update_ocean_display()
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			var height = elementTileMap.get_cell(i, j) % TILES_IN_SET
			if height < Global.oceanLevel:
				clear_units(Vector2(i, j))
				oceanTileMap.set_cell(i, j, (height * TILES_IN_SET) + Global.oceanLevel)
			else:
				oceanTileMap.set_cell(i, j, -1)
	
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
