# Condense values into arrays
# Base Cube
# Water Cube
# Infrastructure array
#  - Small Houses for light infrastructure (between 1 and 4 houses)
#  - Once large, tall building for heavy infrastructure
#  - Trees (triangle) for park

# Stores information for collision polygon (which can be clicked on)
# Information for how to draw each tile based on properties
extends Area2D

var i = 0
var j = 0
var x = 0
var y = 0

var building_visible = true

var base_cube = [Polygon2D.new(), Polygon2D.new(), Polygon2D.new()]
var water_cube = [Polygon2D.new(), Polygon2D.new(), Polygon2D.new()]

var h1 = [Polygon2D.new(), Polygon2D.new(), Polygon2D.new()]
var h2 = [Polygon2D.new(), Polygon2D.new(), Polygon2D.new()]
var h3 = [Polygon2D.new(), Polygon2D.new(), Polygon2D.new()]
var h4 = [Polygon2D.new(), Polygon2D.new(), Polygon2D.new()]

var top_building_poly = Polygon2D.new()
var left_building_poly = Polygon2D.new()
var right_building_poly = Polygon2D.new()

var coll = CollisionPolygon2D.new()

func _ready():
	update_polygons()
	self.add_child(coll)

func _draw():
	update_polygons()
	
	var baseColor = get_cube_colors()
	var waterColor = Global.WATER
	
	if Global.tileMap[i][j].baseHeight > 0:
		draw_polygon(base_cube[1].get_polygon(), PoolColorArray([baseColor[1]]))
		draw_polygon(base_cube[2].get_polygon(), PoolColorArray([baseColor[2]]))

	# If water exists on tile, draw the water cube - otherwise draw the top of the base cube
	if Global.tileMap[i][j].waterHeight > 0:
		draw_polygon(water_cube[1].get_polygon(), PoolColorArray([waterColor[1]]))
		draw_polygon(water_cube[2].get_polygon(), PoolColorArray([waterColor[2]]))
		draw_polygon(water_cube[0].get_polygon(), PoolColorArray([waterColor[0]]))
		draw_polyline(water_cube[0].get_polygon(), waterColor[3])
	else:
		draw_polygon(base_cube[0].get_polygon(), PoolColorArray([baseColor[0]]))
		draw_polyline(base_cube[0].get_polygon(), baseColor[3])

	# Draw building if present
	if Global.tileMap[i][j].inf == 3 && building_visible:
		draw_polygon(left_building_poly.get_polygon(), PoolColorArray([Color("ff777777")]))
		draw_polygon(right_building_poly.get_polygon(), PoolColorArray([Color("ff888888")]))
		draw_polygon(top_building_poly.get_polygon(), PoolColorArray([Color("ff999999")]))
		draw_polyline(top_building_poly.get_polygon(), Color("ff666666"))

	draw_polygon(h1[1].get_polygon(), PoolColorArray([Color("ff777777")]))
	draw_polygon(h1[2].get_polygon(), PoolColorArray([Color("ff888888")]))
	draw_polygon(h1[0].get_polygon(), PoolColorArray([Color("ff999999")]))
	draw_polyline(h1[0].get_polygon(), Color("ff666666"))

	draw_polygon(h2[1].get_polygon(), PoolColorArray([Color("ff777777")]))
	draw_polygon(h2[2].get_polygon(), PoolColorArray([Color("ff888888")]))
	draw_polygon(h2[0].get_polygon(), PoolColorArray([Color("ff999999")]))
	draw_polyline(h2[0].get_polygon(), Color("ff666666"))

	draw_polygon(h3[1].get_polygon(), PoolColorArray([Color("ff777777")]))
	draw_polygon(h3[2].get_polygon(), PoolColorArray([Color("ff888888")]))
	draw_polygon(h3[0].get_polygon(), PoolColorArray([Color("ff999999")]))
	draw_polyline(h3[0].get_polygon(), Color("ff666666"))

	draw_polygon(h4[1].get_polygon(), PoolColorArray([Color("ff777777")]))
	draw_polygon(h4[2].get_polygon(), PoolColorArray([Color("ff888888")]))
	draw_polygon(h4[0].get_polygon(), PoolColorArray([Color("ff999999")]))
	draw_polyline(h4[0].get_polygon(), Color("ff666666"))

func update_polygons():
	var h = Global.tileMap[i][j].baseHeight
	var w = Global.tileMap[i][j].waterHeight
	
	update_cube(base_cube, x, y, Global.TILE_WIDTH, Global.TILE_HEIGHT, h, 0)
	update_cube(water_cube, x, y, Global.TILE_WIDTH, Global.TILE_HEIGHT, h + w, h)
	
	var house_width = Global.TILE_WIDTH / 4.0
	var house_depth = house_width / 2.0
	var house_height = 5
	
	var h1_x = x
	var h1_y = y - h + ((Global.TILE_HEIGHT / 2.0) - house_depth) / 2.0
	
	var h2_x = x
	var h2_y = y - h + ((Global.TILE_HEIGHT / 2.0) - house_depth) / 2.0 + (Global.TILE_HEIGHT / 2.0)
	
	var h3_x = x - (((Global.TILE_WIDTH / 2.0) - house_width) / 2.0) - (house_width / 2.0)
	var h3_y = y - h + ((Global.TILE_HEIGHT / 2.0)) - (house_depth / 2.0)
	
	var h4_x = x + (((Global.TILE_WIDTH / 2.0) - house_width) / 2.0) + (house_width / 2.0)
	var h4_y = y - h + ((Global.TILE_HEIGHT / 2.0)) - (house_depth / 2.0)
	
	update_cube(h1, h1_x, h1_y, house_width, house_depth, house_height, w)
	update_cube(h2, h2_x, h2_y, house_width, house_depth, house_height, w)
	update_cube(h3, h3_x, h3_y, house_width, house_depth, house_height, w)
	update_cube(h4, h4_x, h4_y, house_width, house_depth, house_height, w)
	
	# Set the clickable area of the polygon (the entire base cube)
	coll.set_polygon(PoolVector2Array([
		Vector2(x, y - h), 
		Vector2(x + (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), 
		Vector2(x + (Global.TILE_WIDTH / 2.0), y + (Global.TILE_HEIGHT / 2.0)), 
		Vector2(x, y + Global.TILE_HEIGHT), 
		Vector2(x - (Global.TILE_WIDTH / 2.0), y + (Global.TILE_HEIGHT/2.0)), 
		Vector2(x - (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), 
		Vector2(x, y - h)
		]))

	if Global.tileMap[i][j].zone == 1 && Global.tileMap[i][j].inf == 3:
		var b_width = 8 + (2 * Global.tileMap[i][j].data[0])
		var b_height = 4 + (2 * Global.tileMap[i][j].data[0])
		
		if w > b_height:
			building_visible = false
		else:
			building_visible = true

		top_building_poly.set_polygon( PoolVector2Array([
				Vector2(x, y - h + (Global.TILE_HEIGHT / 2.0) - (b_width / 2.0) - b_height),
				Vector2(x + b_width, y - h + (Global.TILE_HEIGHT / 2.0) - b_height), 
				Vector2(x, y - h + (Global.TILE_HEIGHT / 2.0) + (b_width / 2.0) - b_height),
				Vector2(x - b_width, y - h + (Global.TILE_HEIGHT / 2.0) - b_height),
				Vector2(x, y - h + (Global.TILE_HEIGHT / 2.0) - (b_width / 2.0) - b_height)
				]))

		left_building_poly.set_polygon( PoolVector2Array([
				Vector2(x - b_width, y - h + (Global.TILE_HEIGHT / 2.0) - b_height),
				Vector2(x, y - h + (Global.TILE_HEIGHT / 2.0) + (b_width / 2.0) - b_height),
				Vector2(x, y - h + (Global.TILE_HEIGHT / 2.0) + (b_width / 2.0) - w),
				Vector2(x - b_width, y - h + (Global.TILE_HEIGHT / 2.0) - w)
				]))

		right_building_poly.set_polygon( PoolVector2Array([
				Vector2(x + b_width, y - h + (Global.TILE_HEIGHT / 2.0) - b_height), 
				Vector2(x, y - h + (Global.TILE_HEIGHT / 2.0) + (b_width / 2.0) - b_height),
				Vector2(x, y - h + (Global.TILE_HEIGHT / 2.0) + (b_width / 2.0) - w),
				Vector2(x + b_width, y - h + (Global.TILE_HEIGHT / 2.0) - w)
				]))

func get_cube_colors():
	match Global.tileMap[i][j].base:
		Tile.TileBase.DIRT:
			match Global.tileMap[i][j].inf:
				1:
					return Global.ROAD
				2:
					return Global.PARK
					
			match Global.tileMap[i][j].zone:
				Tile.TileZone.RESIDENTIAL:
					return Global.R_ZONE
				Tile.TileZone.COMMERCIAL:
					return Global.C_ZONE
				Tile.TileZone.INDUSTRIAL:
					return Global.I_ZONE
		Tile.TileBase.SAND:
			return Global.SAND
		Tile.TileBase.OCEAN:
			return Global.WATER
		Tile.TileBase.ROCK:
			return Global.ROCK
	
	return Global.DIRT
	
# Updates the given cube (array of three polygons) given its starting point, width, depth, height, and height offset (for layers)
func update_cube(cube, cube_x, cube_y, width, depth, height, offset):
	# Top of cube
	cube[0].set_polygon(PoolVector2Array([
		Vector2(cube_x, cube_y - height), 
		Vector2(cube_x + (width / 2.0), cube_y - height + (depth / 2.0)), 
		Vector2(cube_x, cube_y - height + depth), 
		Vector2(cube_x - (width / 2.0), cube_y - height + (depth / 2.0)), 
		Vector2(cube_x, cube_y - height)
		]))
	
	# Left side of cube
	cube[1].set_polygon(PoolVector2Array([
		Vector2(cube_x, cube_y - offset + depth),
		Vector2(cube_x, cube_y - height + depth),
		Vector2(cube_x - (width / 2.0), cube_y - height + (depth / 2.0)),
		Vector2(cube_x - (width / 2.0), cube_y - offset + (depth / 2.0))
		]))
	
	# Right side of cube
	cube[2].set_polygon(PoolVector2Array([
		Vector2(cube_x, cube_y - height + depth), 
		Vector2(cube_x, cube_y - offset + depth), 
		Vector2(cube_x + (width / 2.0), cube_y - offset + (depth / 2.0)), 
		Vector2(cube_x + (width / 2.0), cube_y - height + (depth / 2.0))
		]))

func set_index(a, b):
	self.i = a
	self.j = b
	x = (i * (Global.TILE_WIDTH / 2.0)) + (j * (-Global.TILE_WIDTH / 2.0))
	y = (i * (Global.TILE_HEIGHT / 2.0)) + (j * (Global.TILE_HEIGHT / 2.0))
	update_polygons()

# Changes x/y values without altering i/j values (used for camera rotation)
func adjust_coordinates(a, b):
	x = (a * (Global.TILE_WIDTH / 2.0)) + (b * (-Global.TILE_WIDTH / 2.0))
	y = (a * (Global.TILE_HEIGHT / 2.0)) + (b * (Global.TILE_HEIGHT / 2.0))
	update_polygons()
