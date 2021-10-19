# Next Steps:
# - Draw Dirt, Sand, Water
# - Get height data from outside script
# - Other layers for zoning

extends Polygon2D

const TILE_WIDTH = 64
const TILE_HEIGHT = 32

const DIRT_TOP = Color("ffc59d76")
const DIRT_LEFT_SIDE = Color("ffbb8d5d")
const DIRT_RIGHT_SIDE = Color("ff9e7758")
const DIRT_OUTLINE = Color("ff666666")

var colors = PoolColorArray()

var rng = RandomNumberGenerator.new()
	
func _ready():
	pass

func _draw():
	rng.randomize()
	var h = 0
	
	for y in 10:
		h = 30
		for x in 10:
			h -= rng.randi_range(2, 4)
			h += rng.randi_range(0, 2)
			draw_cube(x, y, h)

# Draw a "3D" cube of height h
func draw_cube(tile_x, tile_y, h):
	var x = (tile_x * (TILE_WIDTH / 2.0)) + (tile_y * (-TILE_WIDTH / 2.0))
	var y = (tile_x * (TILE_HEIGHT / 2.0)) + (tile_y * (TILE_HEIGHT / 2.0))

	var top = PoolVector2Array([Vector2(x, y - h), Vector2(x + (TILE_WIDTH / 2.0), y - h + (TILE_HEIGHT / 2.0)), 
	Vector2(x, y - h + TILE_HEIGHT), Vector2(x - (TILE_WIDTH / 2.0), y - h + (TILE_HEIGHT / 2.0)), Vector2(x, y - h)])

	var left_side = PoolVector2Array([Vector2(x, y - h + TILE_HEIGHT), Vector2(x, y + TILE_HEIGHT), 
	Vector2(x - (TILE_WIDTH / 2.0), y + (TILE_HEIGHT/2.0)), Vector2(x - (TILE_WIDTH / 2.0), y - h + (TILE_HEIGHT / 2.0))])
	
	var right_side = PoolVector2Array([Vector2(x, y - h + TILE_HEIGHT), Vector2(x, y + TILE_HEIGHT), 
	Vector2(x + (TILE_WIDTH / 2.0), y + (TILE_HEIGHT/2)), Vector2(x + (TILE_WIDTH / 2.0), y - h + (TILE_HEIGHT / 2.0))])
	
	var top_color = PoolColorArray([DIRT_TOP])
	var left_color = PoolColorArray([DIRT_LEFT_SIDE])
	var right_color = PoolColorArray([DIRT_RIGHT_SIDE])
	
	draw_polygon(top, top_color)
	draw_polygon(left_side, left_color)
	draw_polygon(right_side, right_color)
	draw_polyline(top, DIRT_OUTLINE)
