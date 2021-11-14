# Stores information for collision polygon (which can be clicked on)
# Information for how to draw each tile based on properties
extends Area2D

var i = 0
var j = 0
var x = 0
var y = 0

var top_poly = Polygon2D.new()
var left_poly = Polygon2D.new()
var right_poly = Polygon2D.new()
var left_water_poly = Polygon2D.new()
var right_water_poly = Polygon2D.new()
var top_water_poly = Polygon2D.new()
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
	var h = Global.tileMap[i][j].height
	
	left_poly.set_polygon(PoolVector2Array([Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x, y + Global.TILE_HEIGHT), 
		Vector2(x - (Global.TILE_WIDTH / 2.0), y + (Global.TILE_HEIGHT/2.0)), Vector2(x - (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0))]))
	
	right_poly.set_polygon(PoolVector2Array([Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x, y + Global.TILE_HEIGHT), 
		Vector2(x + (Global.TILE_WIDTH / 2.0), y + (Global.TILE_HEIGHT / 2.0)), Vector2(x + (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0))]))
	
	#If translucent water is desired, we need to draw the top of the land. 
	#Unclear on how to properly YSort since it will put this ahead of the water's top piece
	#For the time being, keeping opaque water
	#top_poly.set_polygon(PoolVector2Array([Vector2(x, y - h), Vector2(x + (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), 
	#	Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x - (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), Vector2(x, y - h)]))
	
	if Global.tileMap[i][j].flooded:
		var w = Global.tileMap[i][j].waterHeight
		
		left_water_poly.set_polygon(PoolVector2Array([Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x, y - h - w + Global.TILE_HEIGHT), 
			Vector2(x - (Global.TILE_WIDTH / 2.0), y - h - w + (Global.TILE_HEIGHT / 2.0)), Vector2(x - (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0))]))
		
		right_water_poly.set_polygon(PoolVector2Array([Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x, y - h - w + Global.TILE_HEIGHT), 
			Vector2(x + (Global.TILE_WIDTH / 2.0), y - h - w + (Global.TILE_HEIGHT / 2.0)), Vector2(x + (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0))]))
		
		top_water_poly.set_polygon(PoolVector2Array([Vector2(x, y - h - w), Vector2(x + (Global.TILE_WIDTH / 2.0), y - h - w + (Global.TILE_HEIGHT / 2.0)), 
			Vector2(x, y - h - w + Global.TILE_HEIGHT), Vector2(x - (Global.TILE_WIDTH / 2.0), y - h - w + (Global.TILE_HEIGHT / 2.0)), Vector2(x, y - h - w)]))
	else:
		top_poly.set_polygon(PoolVector2Array([Vector2(x, y - h), Vector2(x + (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), 
			Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x - (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), Vector2(x, y - h)]))
	
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
	
	return Global.DIRT
	
func _draw():
	var colors = get_cube_colors()
	var waterColors = Global.WATER
	
	if Global.tileMap[i][j].height > 0:
		draw_polygon(left_poly.get_polygon(), PoolColorArray([colors[1]]))
		draw_polygon(right_poly.get_polygon(), PoolColorArray([colors[2]]))
	if Global.tileMap[i][j].flooded:
		draw_polygon(left_water_poly.get_polygon(), PoolColorArray([waterColors[1]]))
		draw_polygon(right_water_poly.get_polygon(), PoolColorArray([waterColors[2]]))
		draw_polygon(top_water_poly.get_polygon(), PoolColorArray([waterColors[0]]))
		draw_polyline(top_water_poly.get_polygon(), waterColors[3])
	else:
		draw_polygon(top_poly.get_polygon(), PoolColorArray([colors[0]]))
		draw_polyline(top_poly.get_polygon(), colors[3])
