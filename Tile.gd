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

var x
var y
var height
var zone
var base
var top = Polygon2D.new()
var left_side = Polygon2D.new()
var right_side = Polygon2D.new()

func _init(i, j):
	x = i
	y = j

	height = 0
	zone = TileZone.NONE
	base = TileBase.DIRT

func raise_tile():
	height += 3
	if height > Global.MAX_HEIGHT:
		height = Global.MAX_HEIGHT

func lower_tile():
	height -= 3
	if height < 0:
		height = 0

func is_dirt():
	return base == 0

func is_sand():
	return base == 1
	
func is_water():
	return base == 2

func _ready():
	pass
