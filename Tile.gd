# Tile data object which stores properties about each tile cube

extends Object

class_name Tile

enum TileBase {
	DIRT,
	SAND,
	WATER
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
var height
var zone
var base
var inf
var cube = Area2D.new()
var water_cube = Area2D.new()
var flooded = false

func _init(a, b):
	self.i = a
	self.j = b

	var rng = RandomNumberGenerator.new()
	rng.randomize()
	height = rng.randi_range(0, 20)
	zone = TileZone.NONE
	inf = TileInf.NONE
	base = TileBase.DIRT

func clear_tile():
	zone = TileZone.NONE
	inf = TileInf.NONE

func raise_tile():
	height += 2
	if height > Global.MAX_HEIGHT:
		height = Global.MAX_HEIGHT
	cube.update_polygons()

func lower_tile():
	height -= 2
	if height < 0:
		height = 0
	cube.update_polygons()

func is_dirt():
	return base == 0

func is_sand():
	return base == 1
	
func is_water():
	return base == 2

func set_base(b):
	match b:
		"DIRT":
			base = TileBase.DIRT
		"SAND":
			base = TileBase.SAND
		"WATER":
			base = TileBase.WATER



func _ready():
	pass
