# Parent node for all of the map cubes
extends YSort

const cube_script = preload("res://TileCube.gd")

# Initialize all map tile cubes and collision polygons
func _ready():
	for i in Global.mapHeight:
		for j in Global.mapWidth:			
			Global.tileMap[i][j].cube.set_script(cube_script)
			Global.tileMap[i][j].cube.set_index(i, j)
			Global.tileMap[i][j].cube.set_pickable(true)
			self.add_child(Global.tileMap[i][j].cube)

func clearNodes():
	for x in get_children():
		x.queue_free()

func reinitMap():
	clearNodes()
	for i in Global.mapHeight:
		for j in Global.mapWidth:			
			Global.tileMap[i][j].cube.set_script(cube_script)
			Global.tileMap[i][j].cube.set_index(i, j)
			Global.tileMap[i][j].cube.set_pickable(true)
			self.add_child(Global.tileMap[i][j].cube)

# Draws all of the individual cubes in the map space
func _draw():	
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			Global.tileMap[i][j].cube.update()

# Returns the tile cube at the provided mouse x/y pixel position (pos)
func get_tile_at(pos):
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_point(pos, 32, [], 0x7FFFFFFF, true, true)
	if result:
		var cube = result[0].collider
		if result.size() > 1:
			var c2 = result[1].collider
			if c2.y > cube.y:
				cube = c2
		return cube
	return null

# Assign new x/y values for each tile based on camera direction
func rotate_map():
	var a = 0
	var b = 0
	
	match Global.camDirection:
		0, 2:
			for i in Global.rowRange:
				for j in Global.colRange:
					var cube = Global.tileMap[i][j].cube
					self.remove_child(cube)
					cube.adjust_coordinates(a, b)
					self.add_child(cube)
					b += 1
				a += 1
				b = 0
		1, 3:
			for j in Global.colRange:
				for i in Global.rowRange:
					var cube = Global.tileMap[i][j].cube
					self.remove_child(cube)
					cube.adjust_coordinates(a, b)
					self.add_child(cube)
					b += 1
				a += 1
				b = 0
