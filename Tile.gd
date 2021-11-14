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

func _init(a, b, c, d, e, f):
	self.i = a
	self.j = b

	height = c
	base = d
	zone = e
	inf = f

func clear_tile():
	zone = TileZone.NONE
	inf = TileInf.NONE

func raise_tile():
	height += 1
	if height > Global.MAX_HEIGHT:
		height = Global.MAX_HEIGHT
	cube.update_polygons()

func lower_tile():
	height -= 1
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
			base = 0
		"SAND":
			base = 1
		"WATER":
			base = 2

func _ready():
	pass
