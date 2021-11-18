# Stores information for collision polygon (which can be clicked on)
# Information for how to draw each tile based on properties
extends Area2D

var i = 0
var j = 0
var x = 0
var y = 0

var top_base_poly = Polygon2D.new()
var left_base_poly = Polygon2D.new()
var right_base_poly = Polygon2D.new()

var top_water_poly = Polygon2D.new()
var left_water_poly = Polygon2D.new()
var right_water_poly = Polygon2D.new()

var coll = CollisionPolygon2D.new()

func _ready():
	update_polygons()
	self.add_child(coll)

func set_index(a, b):
	self.i = a
	self.j = b
	x = (i * (Global.TILE_WIDTH / 2.0)) + (j * (-Global.TILE_WIDTH / 2.0))
	y = (i * (Global.TILE_HEIGHT / 2.0)) + (j * (Global.TILE_HEIGHT / 2.0))
	update_polygons()

# Used to rotate map, changes x/y values without altering i/j values
func adjust_coordinates(a, b):
	x = (a * (Global.TILE_WIDTH / 2.0)) + (b * (-Global.TILE_WIDTH / 2.0))
	y = (a * (Global.TILE_HEIGHT / 2.0)) + (b * (Global.TILE_HEIGHT / 2.0))
	update_polygons()

func update_polygons():
	var h = Global.tileMap[i][j].baseHeight
	var w = Global.tileMap[i][j].waterHeight
	
	top_base_poly.set_polygon(PoolVector2Array([Vector2(x, y - h), Vector2(x + (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), 
			Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x - (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), Vector2(x, y - h)]))
			
	left_base_poly.set_polygon(PoolVector2Array([Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x, y + Global.TILE_HEIGHT), 
		Vector2(x - (Global.TILE_WIDTH / 2.0), y + (Global.TILE_HEIGHT/2.0)), Vector2(x - (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0))]))
	
	right_base_poly.set_polygon(PoolVector2Array([Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x, y + Global.TILE_HEIGHT), 
		Vector2(x + (Global.TILE_WIDTH / 2.0), y + (Global.TILE_HEIGHT / 2.0)), Vector2(x + (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0))]))
	
	top_water_poly.set_polygon(PoolVector2Array([Vector2(x, y - h - w), Vector2(x + (Global.TILE_WIDTH / 2.0), y - h - w + (Global.TILE_HEIGHT / 2.0)), 
			Vector2(x, y - h - w + Global.TILE_HEIGHT), Vector2(x - (Global.TILE_WIDTH / 2.0), y - h - w + (Global.TILE_HEIGHT / 2.0)), Vector2(x, y - h - w)]))
					
	left_water_poly.set_polygon(PoolVector2Array([Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x, y - h - w + Global.TILE_HEIGHT), 
			Vector2(x - (Global.TILE_WIDTH / 2.0), y - h - w + (Global.TILE_HEIGHT / 2.0)), Vector2(x - (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0))]))
		
	right_water_poly.set_polygon(PoolVector2Array([Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x, y - h - w + Global.TILE_HEIGHT), 
			Vector2(x + (Global.TILE_WIDTH / 2.0), y - h - w + (Global.TILE_HEIGHT / 2.0)), Vector2(x + (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0))]))
	
	coll.set_polygon(PoolVector2Array([Vector2(x, y - h), Vector2(x + (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), 
		Vector2(x + (Global.TILE_WIDTH / 2.0), y + (Global.TILE_HEIGHT / 2.0)), Vector2(x, y + Global.TILE_HEIGHT), 
		Vector2(x - (Global.TILE_WIDTH / 2.0), y + (Global.TILE_HEIGHT/2.0)), Vector2(x - (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), Vector2(x, y - h)]))

func get_cube_colors():
	match Global.tileMap[i][j].base:
		0:
			match Global.tileMap[i][j].inf:
				1:
					return Global.ROAD
				2:
					return Global.PARK
					
			match Global.tileMap[i][j].zone:
				1:
					return Global.R_ZONE
				2:
					return Global.C_ZONE
				3:
					return Global.I_ZONE
		1:
			return Global.SAND
		2:
			return Global.WATER
		3:
			return Global.ROCK
	
	return Global.DIRT
	
func _draw():
	var baseColor = get_cube_colors()
	var waterColor = Global.WATER
	
	if Global.tileMap[i][j].baseHeight > 0:
		draw_polygon(left_base_poly.get_polygon(), PoolColorArray([baseColor[1]]))
		draw_polygon(right_base_poly.get_polygon(), PoolColorArray([baseColor[2]]))

	if Global.tileMap[i][j].waterHeight > 0:
		draw_polygon(left_water_poly.get_polygon(), PoolColorArray([waterColor[1]]))
		draw_polygon(right_water_poly.get_polygon(), PoolColorArray([waterColor[2]]))
		draw_polygon(top_water_poly.get_polygon(), PoolColorArray([waterColor[0]]))
		draw_polyline(top_water_poly.get_polygon(), waterColor[3])
	else:
		draw_polygon(top_base_poly.get_polygon(), PoolColorArray([baseColor[0]]))
		draw_polyline(top_base_poly.get_polygon(), baseColor[3])
