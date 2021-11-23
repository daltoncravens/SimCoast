# Information for how to draw each tile based on properties
extends Area2D

var i = 0
var j = 0
var x = 0
var y = 0

var building_visible = true

var base_cube = [Polygon2D.new(), Polygon2D.new(), Polygon2D.new()]
var water_cube = [Polygon2D.new(), Polygon2D.new(), Polygon2D.new()]
var objects = []

var coll = CollisionPolygon2D.new()

func _ready():
	update_polygons()
	self.add_child(coll)

func _draw():
	update_polygons()
	
	var tile = Global.tileMap[i][j]
		
	var baseColor = get_cube_colors()
	var waterColor = Tile.WATER_COLOR
	var buildingColor = get_building_colors()
	
	if tile.get_base_height() > 0:
		draw_polygon(base_cube[1].get_polygon(), PoolColorArray([baseColor[1]]))
		draw_polygon(base_cube[2].get_polygon(), PoolColorArray([baseColor[2]]))

	# If water exists on tile, draw the water cube - otherwise draw the top of the base cube
	if tile.get_water_height() > 0:
		draw_polygon(water_cube[1].get_polygon(), PoolColorArray([waterColor[1]]))
		draw_polygon(water_cube[2].get_polygon(), PoolColorArray([waterColor[2]]))
		draw_polygon(water_cube[0].get_polygon(), PoolColorArray([waterColor[0]]))
		draw_polyline(water_cube[0].get_polygon(), waterColor[3])
	else:
		draw_polygon(base_cube[0].get_polygon(), PoolColorArray([baseColor[0]]))
		draw_polyline(base_cube[0].get_polygon(), baseColor[3])

	# Draw building(s) if present
	if tile.has_building() && building_visible:
		for b in objects:
			draw_polygon(b[1].get_polygon(), PoolColorArray([buildingColor[1]]))
			draw_polygon(b[2].get_polygon(), PoolColorArray([buildingColor[2]]))
			draw_polygon(b[0].get_polygon(), PoolColorArray([buildingColor[0]]))
			draw_polyline(b[0].get_polygon(), buildingColor[3])

	if tile.inf == Tile.TileInf.PARK:
		for t in objects:
			draw_polygon(t[0].get_polygon(), PoolColorArray([Tile.TREE_COLOR[0]]))
			draw_polygon(t[1].get_polygon(), PoolColorArray([Tile.TREE_COLOR[1]]))

func update_polygons():
	var tile = Global.tileMap[i][j]
	var h = tile.get_base_height()
	var w = tile.get_water_height()
	
	update_cube(base_cube, x, y, Global.TILE_WIDTH, Global.TILE_HEIGHT, h, 0)
	update_cube(water_cube, x, y, Global.TILE_WIDTH, Global.TILE_HEIGHT, h + w, h)
	
	# Create simple trees so landscape not so boring
	if tile.inf == Tile.TileInf.PARK:
		objects.clear()
		var tree_width = 0
		var tree_depth = 0
		var tree_height = 0
		var tree_x = 0
		var tree_y = 0
		
		for z in 3:
			var t = [Polygon2D.new(), Polygon2D.new()]
				
			match z:
				0:
					tree_height = 12
					if w >= tree_height:
						tree_height = 0
					
					tree_width = tree_height
					tree_depth = tree_width / 2.0
					
					tree_x = x + (Global.TILE_WIDTH / 4.0) - (tree_width / 2.0)
					tree_y = y - h + ((Global.TILE_HEIGHT / 2.5)) - (tree_depth / 2.0)
				1:
					tree_height = 16
					if w >= tree_height:
						tree_height = 0
					
					tree_width = tree_height
					tree_depth = tree_width / 2.0
					
					tree_x = x - (Global.TILE_WIDTH / 6.0)
					tree_y = y - h + (Global.TILE_HEIGHT / 2.5) - (tree_depth / 2.0)
				2:
					tree_height = 10
					if w >= tree_height:
						tree_height = 0
					
					tree_width = tree_height
					tree_depth = tree_width / 2.0
					
					tree_x = x
					tree_y = y - h + (0.7 * Global.TILE_HEIGHT) - (tree_depth / 2.0)
			
			update_tree(t, tree_x, tree_y, tree_width, tree_depth, tree_height, w)
			objects.append(t)
	
	if tile.has_building():
		objects.clear()
		var num_buildings = tile.get_number_of_buildings()
		
		var building_width = 0
		var building_depth = 0
		var building_height = 0
		var building_x = 0
		var building_y = 0

		if tile.is_light_zoned():
			building_width = Global.TILE_WIDTH / 4.0
			building_depth = building_width / 2.0
			building_height = 5
			
			if w > building_height:
				building_visible = false
			else:
				building_visible = true
			
			for z in num_buildings:
				var b = [Polygon2D.new(), Polygon2D.new(), Polygon2D.new()]
				
				match z:
					0:
						building_x = x
						building_y = y - h + ((Global.TILE_HEIGHT / 2.0) - building_depth) / 2.0
					1:
						building_x = x
						building_y = y - h + ((Global.TILE_HEIGHT / 2.0) - building_depth) / 2.0 + (Global.TILE_HEIGHT / 2.0)
					2:
						building_x = x - (((Global.TILE_WIDTH / 2.0) - building_width) / 2.0) - (building_width / 2.0)
						building_y = y - h + ((Global.TILE_HEIGHT / 2.0)) - (building_depth / 2.0)
					3:
						building_x = x + (((Global.TILE_WIDTH / 2.0) - building_width) / 2.0) + (building_width / 2.0)
						building_y = y - h + ((Global.TILE_HEIGHT / 2.0)) - (building_depth / 2.0)
			
				update_cube(b, building_x, building_y, building_width, building_depth, building_height, w)
				objects.append(b)

		# Draws a single buildings, scaled to number of buildings
		elif tile.is_heavy_zoned():
			building_width = (Global.TILE_WIDTH / 2.0) + (2 * num_buildings) 
			building_depth = building_width / 2.0
			building_height = 10 + (3 * num_buildings)

			if w > building_height:
				building_visible = false
			else:
				building_visible = true
			
			var b = [Polygon2D.new(), Polygon2D.new(), Polygon2D.new()]
			
			building_x = x
			building_y = y - h + ((Global.TILE_HEIGHT / 2.0) - (building_depth / 2.0))

			update_cube(b, building_x, building_y, building_width, building_depth, building_height, w)
			objects.append(b)
	
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

# Returns a buildings color based on tile status (occupied, damaged, etc.)
func get_building_colors():	
	# If damaged, return status color 
	match Global.tileMap[i][j].get_status():
		Tile.TileStatus.LIGHT_DAMAGE:
			return Tile.LIGHT_DAMAGE_COLOR
		Tile.TileStatus.MEDIUM_DAMAGE:
			return Tile.MEDIUM_DAMAGE_COLOR
		Tile.TileStatus.HEAVY_DAMAGE:
			return Tile.HEAVY_DAMAGE_COLOR

	# Return building color based on zone
	return Tile.BUILDING_COLOR

# Returns cube colors for base cube
func get_cube_colors():
	var tile = Global.tileMap[i][j]
	var colors = []
	
	match tile.get_base():
		Tile.TileBase.DIRT:
			colors = Tile.DIRT_COLOR.duplicate(true)
		Tile.TileBase.ROCK:
			colors = Tile.ROCK_COLOR.duplicate(true)
		Tile.TileBase.SAND:
			colors = Tile.SAND_COLOR.duplicate(true)
		Tile.TileBase.OCEAN:
			colors = Tile.WATER_COLOR.duplicate(true)

	# Change base top color and outline if tile is zoned
	match tile.get_zone():
		Tile.TileZone.LIGHT_RESIDENTIAL:
			colors[0] = Tile.LT_RES_ZONE_COLOR[0]
			colors[3] = Tile.LT_RES_ZONE_COLOR[1]
		Tile.TileZone.HEAVY_RESIDENTIAL:
			colors[0] = Tile.HV_RES_ZONE_COLOR[0]
			colors[3] = Tile.HV_RES_ZONE_COLOR[1]
		Tile.TileZone.LIGHT_COMMERCIAL:
			colors[0] = Tile.LT_COM_ZONE_COLOR[0]
			colors[3] = Tile.LT_COM_ZONE_COLOR[1]
		Tile.TileZone.HEAVY_COMMERCIAL:
			colors[0] = Tile.HV_COM_ZONE_COLOR[0]
			colors[3] = Tile.HV_COM_ZONE_COLOR[1]

	match tile.inf:
		Tile.TileInf.PARK:
			colors[0] = Tile.PARK_COLOR[0]
			colors[3] = Tile.PARK_COLOR[1]

	return colors
	
# Update the given tree based on its starting coordintes and properties
func update_tree(tree, tree_x, tree_y, width, depth, height, offset):
	# Left side of tree
	tree[0].set_polygon(PoolVector2Array([
		Vector2(tree_x, tree_y - height + (depth / 2.0)),
		Vector2(tree_x, tree_y - offset + depth),
		Vector2(tree_x - (width / 2.0), tree_y - offset + (depth / 2.0))
		]))
	# Right side of tree
	tree[1].set_polygon(PoolVector2Array([
		Vector2(tree_x, tree_y - height + (depth / 2.0)), 
		Vector2(tree_x, tree_y - offset + depth), 
		Vector2(tree_x + (width / 2.0), tree_y - offset + (depth / 2.0))
		]))

# Updates the provided cube [array of three polygons] given its starting point, width, depth, height, and height offset (for layers)
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
