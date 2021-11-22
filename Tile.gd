# Tile data object which stores properties about each tile cube

extends Object

class_name Tile

enum TileBase {
	DIRT,
	SAND,
	OCEAN,
	ROCK
}

enum TileZone {
	NONE,
	RESIDENTIAL,
	COMMERCIAL,
	LIGHT_RESIDENTIAL,
	HEAVY_RESIDENTIAL,
	LIGHT_COMMERCIAL,
	HEAVY_COMMERCIAL
}

enum TileInf {
	NONE,
	ROAD,
	PARK,
	HOUSE,
	BUILDING
}

# Used to determine color of buildings
enum TileStatus {
	UNOCCUPIED,
	OCCUPIED,
	LIGHT_DAMAGE,
	MEDIUM_DAMAGE,
	HEAVY_DAMAGE
}

var i
var j
var baseHeight = 0
var waterHeight = 0
var zone
var base
var inf
var cube = Area2D.new()
var data = [0, 0, 0, 0, 0]

func _init(a, b, c, d, e, f, g):
	self.i = a
	self.j = b

	baseHeight = c
	waterHeight = d
	base = e
	zone = f
	inf = g

func clear_tile():
	zone = TileZone.NONE
	inf = TileInf.NONE
	data = [0, 0, 0, 0, 0]

func raise_tile():
	baseHeight += 1
	if baseHeight > Global.MAX_HEIGHT:
		baseHeight = Global.MAX_HEIGHT

func lower_tile():
	baseHeight -= 1
	if baseHeight < 0:
		baseHeight = 0

func raise_water():
	waterHeight += 1
	if (waterHeight + baseHeight) > Global.MAX_HEIGHT:
		waterHeight = Global.MAX_HEIGHT - baseHeight
	cube.update_polygons()

func lower_water():
	waterHeight -= 1
	if waterHeight < 0:
		waterHeight = 0
	cube.update_polygons()

func can_zone():
	return base == TileBase.DIRT || base == TileBase.ROCK

func get_base():
	return base

func set_base(b):
	base = b

func get_base_height():
	return baseHeight

func get_water_height():
	return waterHeight

func get_number_of_buildings():
	if inf == TileInf.BUILDING:
		return data[0]
	else:
		return 0

func set_base_height(h):
	if 0 <= h && h <= Global.MAX_HEIGHT:
		baseHeight = h

func set_water_height(w):
	if 0 <= w && w <= Global.MAX_HEIGHT:
		waterHeight = w

func is_ocean():
	return base == TileBase.OCEAN

# Data is a generic array that stores values based on the type of infrastructure present
# For housing, the data stores and array of the following values:
# - [0] Number of houses present
# - [1] Number of houses maximum
# - [2] People living there
# - [3] Maximum people
# - [4] Status of tile (0: unoccupied, 1: Occupied, 2: Damaged, 3: Severe Damage, 4: Abandonded)

func get_zone():
	return zone

func set_zone(type):
	zone = type
	data = [0, 4, 0, 0, 0]

func add_building():		
	inf = TileInf.HOUSE
	if data[0] < data[1]:
		data[0] += 1
		data[3] += 4

func remove_building():		
	if data[0] <= 1:
		data = [0, 4, 0, 0, 0]
		inf = TileInf.NONE
	
	else:
		data[0] -= 1
		data[3] -= 4
		if data[2] > data[3]:
			data[2] = data[3]

func add_people(n):	
	data[2] += n
	if data[2] > data[3]:
		data[2] = data[3]

func remove_people(n):		
	data[2] -= n
	if data[2] <= 0:
		data[2] = 0
		data[4] = 0

func clear_house():
	if zone != TileZone.RESIDENTIAL:
		return
	
	inf = TileInf.NONE
	data = [0, 0, 0, 0, 0]

func get_data():
	return data

func _ready():
	pass
