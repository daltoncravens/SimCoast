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
	INDUSTRIAL
}

enum TileInf {
	NONE,
	ROAD,
	PARK
}

var i
var j
var baseHeight = 0
var waterHeight = 0
var zone
var base
var inf
var cube = Area2D.new()

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

func raise_tile():
	baseHeight += 1
	if baseHeight > Global.MAX_HEIGHT:
		baseHeight = Global.MAX_HEIGHT
	cube.update_polygons()

func lower_tile():
	baseHeight -= 1
	if baseHeight < 0:
		baseHeight = 0
	cube.update_polygons()

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

func is_dirt():
	return base == TileBase.DIRT

func is_sand():
	return base == TileBase.SAND
	
func is_ocean():
	return base == TileBase.OCEAN

func is_rock():
	return base == TileBase.ROCK

func set_base(b):
	match b:
		"DIRT":
			base = TileBase.DIRT
		"SAND":
			base = TileBase.SAND
		"OCEAN":
			base = TileBase.OCEAN
		"ROCK":
			base = TileBase.ROCK

func _ready():
	pass
