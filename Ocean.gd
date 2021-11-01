# The ocean is one, map sized cube with each base tile rendered visible based on its height
extends Area2D

var x = 0
var y = 0

var top_poly = Polygon2D.new()
var left_poly = Polygon2D.new()
var right_poly = Polygon2D.new()

func _ready():
	update_polygons()

func update_polygons():
	var h = Global.oceanLevel
	
	top_poly.set_polygon(PoolVector2Array([Vector2(x, y - h), Vector2(x + (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), 
		Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x - (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), Vector2(x, y - h)]))
	
	left_poly.set_polygon(PoolVector2Array([Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x, y + Global.TILE_HEIGHT), 
		Vector2(x - (Global.TILE_WIDTH / 2.0), y + (Global.TILE_HEIGHT/2.0)), Vector2(x - (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0))]))
	
	right_poly.set_polygon(PoolVector2Array([Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x, y + Global.TILE_HEIGHT), 
		Vector2(x + (Global.TILE_WIDTH / 2.0), y + (Global.TILE_HEIGHT / 2.0)), Vector2(x + (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0))]))
	
func _draw():
	var colors = Global.WATER
	draw_polygon(left_poly.get_polygon(), PoolColorArray([colors[1]]))
	draw_polygon(right_poly.get_polygon(), PoolColorArray([colors[2]]))
	draw_polygon(top_poly.get_polygon(), PoolColorArray([colors[0]]))
	draw_polyline(top_poly.get_polygon(), colors[3])
