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
	NONE,
	LIGHT_DAMAGE,
	MEDIUM_DAMAGE,
	HEAVY_DAMAGE
}

const DIRT_COLOR = [Color("ffc59d76"), Color("ffbb8d5d"), Color("ff9e7758"), Color("ff666666")]
const SAND_COLOR = [Color("ffd9d3bf"), Color("ffc9bf99"), Color("ffaca075"), Color("ff867d5e")]
const WATER_COLOR = [Color("ff9cd5e2"), Color("ff8bc4d1"), Color("ff83bcc9"), Color("ff5b8c97")]
const ROCK_COLOR = [Color("ffc2c2c2"), Color("ffcacaca"), Color("ffaaaaaa"), Color("ff666666")]

const LT_RES_ZONE_COLOR = [Color("ffbdd0a0"), Color("ff60822d")]
const HV_RES_ZONE_COLOR = [Color("ffa5bf7d"), Color("ff60822d")]
const LT_COM_ZONE_COLOR = [Color("ffa0b4d0"), Color("ff2d5b82")]
const HV_COM_ZONE_COLOR = [Color("ff7d9bbf"), Color("ff2d5b82")]

const BUILDING_COLOR = [Color("ffaaaaaa"), Color("ff999999"), Color("ff888888"), Color("ff777777")]

const LIGHT_DAMAGE_COLOR = [Color("fff2c926"), Color("ffd8bf09"), Color("ffc4ae00"), Color("ffae9a00")]
const MEDIUM_DAMAGE_COLOR = [Color("fff28b26"), Color("ffd86909"), Color("ffac5100"), Color("ffac5100")]
const HEAVY_DAMAGE_COLOR = [Color("fff22627"), Color("ffd80909"), Color("ff7c0000"), Color("ff590000")]

const PARK_COLOR = [Color("ff8bb54a"), Color("ff60822d")]
const TREE_COLOR = [Color("ff4a8a7d"), Color("ff286f61")]

const ROAD_COLOR = [Color("ff6a6a6a"), Color("ff999999")]

var i
var j
var baseHeight = 0
var waterHeight = 0
var zone = 0
var base = 0
var inf = 0
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

func get_status():
	return data[4]

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

func is_light_zoned():
	return zone == TileZone.LIGHT_RESIDENTIAL || zone == TileZone.LIGHT_COMMERCIAL

func is_heavy_zoned():
	return zone == TileZone.HEAVY_RESIDENTIAL || zone == TileZone.HEAVY_COMMERCIAL

func set_base_height(h):
	if 0 <= h && h <= Global.MAX_HEIGHT:
		baseHeight = h

func set_water_height(w):
	if 0 <= w && w <= Global.MAX_HEIGHT:
		waterHeight = w

func can_build():
	if zone == TileZone.LIGHT_RESIDENTIAL || zone == TileZone.HEAVY_RESIDENTIAL:
		return true
	elif zone == TileZone.LIGHT_COMMERCIAL || zone == TileZone.HEAVY_COMMERCIAL:
		return true
	return false

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

func has_building():
	return inf == TileInf.BUILDING

func set_zone(type):
	zone = type
	data = [0, 4, 0, 0, 0]

func add_building():		
	inf = TileInf.BUILDING
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
