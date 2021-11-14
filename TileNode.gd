# Stores information for collision polygon (which can be clicked on)
# Information for how to draw each tile based on properties
extends Area2D

const DIRT_TOP = Color("ffc59d76")
const DIRT_LEFT_SIDE = Color("ffbb8d5d")
const DIRT_RIGHT_SIDE = Color("ff9e7758")
const DIRT_OUTLINE = Color("ff666666")

var i = 0
var j = 0
var x = 0
var y = 0

var top_poly = Polygon2D.new()
var left_poly = Polygon2D.new()
var right_poly = Polygon2D.new()
var coll = CollisionPolygon2D.new()

func _ready():
	update_polygons()
	self.add_child(coll)

func set_coordinates(a, b):
	self.i = a
	self.j = b
	update_polygons()

func update_polygons():
	x = (i * (Global.TILE_WIDTH / 2.0)) + (j * (-Global.TILE_WIDTH / 2.0))
	y = (i * (Global.TILE_HEIGHT / 2.0)) + (j * (Global.TILE_HEIGHT / 2.0))
	var h = Global.tileMap[i][j].height
	
	top_poly.set_polygon(PoolVector2Array([Vector2(x, y - h), Vector2(x + (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), 
		Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x - (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), Vector2(x, y - h)]))
	
	coll.set_polygon(PoolVector2Array([Vector2(x, y - h), Vector2(x + (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), 
		Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x - (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), Vector2(x, y - h)]))
	
	left_poly.set_polygon(PoolVector2Array([Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x, y + Global.TILE_HEIGHT), 
		Vector2(x - (Global.TILE_WIDTH / 2.0), y + (Global.TILE_HEIGHT/2.0)), Vector2(x - (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0))]))
	
	right_poly.set_polygon(PoolVector2Array([Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x, y + Global.TILE_HEIGHT), 
		Vector2(x + (Global.TILE_WIDTH / 2.0), y + (Global.TILE_HEIGHT / 2.0)), Vector2(x + (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0))]))

func _draw():
	if Global.tileMap[i][j].height > 0:
		draw_polygon(left_poly.get_polygon(), PoolColorArray([DIRT_LEFT_SIDE]))
		draw_polygon(right_poly.get_polygon(), PoolColorArray([DIRT_RIGHT_SIDE]))
	draw_polygon(top_poly.get_polygon(), PoolColorArray([DIRT_TOP]))
	draw_polyline(top_poly.get_polygon(), DIRT_OUTLINE)
