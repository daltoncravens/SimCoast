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
	BUILDING,
	BEACH_ROCKS,
	BEACH_GRASS,
	POWER_PLANT
}

# Flooding damage levels that can affect tiles
enum TileStatus {
	NONE,
	LIGHT_DAMAGE,
	MEDIUM_DAMAGE,
	HEAVY_DAMAGE
}

const DIRT_COLOR = [Color("ffc59d76"), Color("ffbb8d5d"), Color("ff9e7758"), Color("ff666666")]
const GRASS_COLOR = [Color("ff8bb54a"), Color("ff60822d")]
const SAND_COLOR = [Color("ffd9d3bf"), Color("ffc9bf99"), Color("ffaca075"), Color("ff867d5e")]
const WATER_COLOR = [Color("ff9cd5e2"), Color("ff8bc4d1"), Color("ff83bcc9"), Color("ff5b8c97")]
const ROCK_COLOR = [Color("ffc2c2c2"), Color("ffcacaca"), Color("ffaaaaaa"), Color("ff666666")]

const LT_RES_ZONE_COLOR = [Color("ffbdd0a0"), Color("ff60822d")]
const HV_RES_ZONE_COLOR = [Color("ffa5bf7d"), Color("ff60822d")]
const LT_COM_ZONE_COLOR = [Color("ffa0b4d0"), Color("ff2d5b82")]
const HV_COM_ZONE_COLOR = [Color("ff7d9bbf"), Color("ff2d5b82")]

const BUILDING_COLOR = [Color("ffaaaaaa"), Color("ff999999"), Color("ff888888"), Color("ff777777")]
const UNPOWERED_BUILDING_COLOR = [Color("ff555555"), Color("ff444444"), Color("ff333333"), Color("ff333333")]

const POWER_PLANT_COLOR = [Color("ff777777"), Color("ff888888"), Color("ff999999"), Color("ff999999")]
const POWER_STACK_COLOR = [Color("ff333333"), Color("ff950000"), Color("ff6a0000"), Color("ff333333")]

const RES_OCCUPANCY_COLOR = [Color("aa2a9d2d"), Color("aa1d851f")]
const COM_OCCUPANCY_COLOR = [Color("aa3779a2"), Color("aa26648b")]

const LIGHT_DAMAGE_COLOR = [Color("ff555555"), Color("ffd8bf09"), Color("ffc4ae00"), Color("ffae9a00")]
const MEDIUM_DAMAGE_COLOR = [Color("ff555555"), Color("ffd86909"), Color("ffac5100"), Color("ffac5100")]
const HEAVY_DAMAGE_COLOR = [Color("ff555555"), Color("ffd80909"), Color("ff7c0000"), Color("ff590000")]

const PARK_COLOR = [Color("ff8bb54a"), Color("ff60822d")]
const TREE_COLOR = [Color("ff4a8a7d"), Color("ff286f61")]
const BEACH_ROCK_COLOR = [Color("ffb8c5d4"), Color("ffa0b3cc"), Color("ff8ca4c0")]

const ROAD_COLOR = [Color("ff6a6a6a"), Color("ff999999")]

var i
var j
var baseHeight = 0
var waterHeight = 0
var base = 0
var zone = 0
var inf = 0
var cube = Area2D.new()
var data = [0, 0, 0, 0, 0]
var powered = false
var tileDamage = 0
# Purchase price of a tile
var landValue = 0
# Income of a zone
var profitRate = 0
var happiness = 0
var changeInWaterHeight = 0

# Economy AI: equation coefficient constants
var desirability = 0.2
const BASE_DESIRABILITY = 0.2
const WATER_CLOSE = 0.1
const WATER_FAR = 0.05
const BASE_DIRT = 0.05
const BASE_ROCK = 0
const BASE_SAND = -0.05
const RESIDENTIAL_NEIGHBOR = 0.05
const COMMERCIAL_NEIGHBOR = 0.10
const INDUSTRIAL_NEIGHBOR = -0.2
const NUMBER_ZONES = 0.01
const NUMBER_PEOPLE = 0.001
const PROP_TAX_HEAVY = -0.1
const PROP_TAX_LOW = 0.05
const SALES_TAX_HEAVY = -0.05
const WEALTH_NEG = -0.05
const WEALTH_DESIRE = 0.025


# Economy AI: Equation variable booleans & values
var is_close_water = false
var is_far_water = false
var tile_base_dirt = false
var tile_base_rock = false
var tile_base_sand = false
var residential_neighbors = 0
var commercial_neighbors = 0
var industrial_neighbors = 0
var prop_tax_weight = 0
var is_sales_tax_heavy = false
var is_neg_profit = false
var wealth_weight = 0
var tile_dmg_weight = 0


func _init(a, b, c, d, e, f, g, h, k, l, m):
	self.i = a
	self.j = b

	baseHeight = c
	waterHeight = d
	base = e
	zone = f
	inf = g
	data = h
	tileDamage = k
	landValue = l
	profitRate = m
	

func get_save_tile_data():
	return [i, j, baseHeight, waterHeight, base, zone, inf, data, tileDamage, landValue, profitRate]

func paste_tile(tile):
	baseHeight = tile.baseHeight
	waterHeight = tile.waterHeight
	base = tile.base
	zone = tile.zone
	inf = tile.inf
	data = tile.data
	tileDamage = tile.tileDamage
	landValue = tile.landValue
	profitRate = tile.profitRate

func clear_tile():
	if zone == TileZone.HEAVY_COMMERCIAL || zone == TileZone.LIGHT_COMMERCIAL:
		tileDamage -= data[0] * Econ.REMOVE_COMMERCIAL_BUILDING
	else:
		tileDamage -= data[0] * Econ.REMOVE_BUILDING_DAMAGE
	if tileDamage < 0:
		tileDamage = 0
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
	changeInWaterHeight = 1
	if (waterHeight + baseHeight) > Global.MAX_HEIGHT:
		waterHeight = Global.MAX_HEIGHT - baseHeight

func lower_water():
	waterHeight -= 1
	changeInWaterHeight = -1
	if waterHeight < 0:
		waterHeight = 0

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

func is_zoned():
	return is_light_zoned() || is_heavy_zoned()

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

func remove_water():
	waterHeight = 0
	changeInWaterHeight = 0

func set_damage(n):
	if n == TileStatus.LIGHT_DAMAGE:
		tileDamage += .25
	elif n == TileStatus.MEDIUM_DAMAGE:
		tileDamage += .5
	elif n == TileStatus.HEAVY_DAMAGE:
		tileDamage += .75
	
		
	if tileDamage < .5:
		data[4] = TileStatus.LIGHT_DAMAGE
	elif tileDamage >=.5 && tileDamage <= .75:
		data[4] = TileStatus.MEDIUM_DAMAGE
	elif tileDamage > .75:
		data[4] = TileStatus.HEAVY_DAMAGE
		
	if tileDamage >= 1:
		tileDamage = 1
		#the tile is completely destroyed at this point
		#should remove all buildings and all population?
		while data[0] > 0:
			remove_building()
		remove_people(data[2])

func is_powered():
	return powered

func get_zone():
	return zone

func has_building():
	return inf == TileInf.BUILDING

func set_zone(type):
	zone = type
	if type == TileZone.HEAVY_COMMERCIAL || type == TileZone.LIGHT_COMMERCIAL:
		profitRate = 10000
	data = [0, 4, 0, 0, 0]

func add_building():		
	inf = TileInf.BUILDING
	if data[0] < data[1]:
		data[0] += 1
		data[3] += 4
	#match(zone):
	#	TileZone.HEAVY_RESIDENTIAL:
	#		Econ.adjust_player_money(-30000)
	#	TileZone.HEAVY_COMMERCIAL:
	#		Econ.adjust_player_money(-40000)
	#	TileZone.LIGHT_COMMERCIAL:
	#		Econ.adjust_player_money(-20000)
	#	TileZone.LIGHT_RESIDENTIAL:
	#		Econ.adjust_player_money(-10000)

func remove_building():		
	if data[0] <= 1:
		data[0] = 0
		data[1] = 4
		data[2] = 0
		data[3] = 0
		inf = TileInf.NONE
	
	else:
		data[0] -= 1
		data[3] -= 4
		if data[2] > data[3]:
			data[2] = data[3]
#	if zone == TileZone.HEAVY_COMMERCIAL || zone == TileZone.LIGHT_COMMERCIAL:
#		tileDamage -= Econ.REMOVE_COMMERCIAL_BUILDING
#	else:
#		tileDamage -= Econ.REMOVE_BUILDING_DAMAGE
	if tileDamage < 0:
		tileDamage = 0

func add_people(n):	
	var before = data[2]
	data[2] += n
	if data[2] > data[3]:
		data[2] = data[3]
	var after = data[2]
	return after - before

func remove_people(n):		
	var before = data[2]
	data[2] -= n
	if data[2] <= 0:
		data[2] = 0
		data[4] = 0
	var after = data[2]
	return after - before

func clear_house():
	if zone != TileZone.RESIDENTIAL:
		return
	
	inf = TileInf.NONE
	data = [0, 0, 0, 0, 0]

func get_data():
	return data

func _ready():
	pass

func is_residential():
	return zone == TileZone.LIGHT_RESIDENTIAL || zone == TileZone.HEAVY_RESIDENTIAL
	
func is_commercial():
	return zone == TileZone.LIGHT_COMMERCIAL || zone == TileZone.HEAVY_COMMERCIAL
