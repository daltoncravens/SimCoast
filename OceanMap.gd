# Parent node for all of the map cubes
extends YSort

const cube_script = preload("res://OceanCube.gd")

# Initialize all map tile cubes and collision polygons
func _ready():
	for i in Global.mapHeight:
		for j in Global.mapWidth:
			Global.tileMap[i][j].water_cube.set_script(cube_script)
			Global.tileMap[i][j].water_cube.set_coordinates(i, j)
			self.add_child(Global.tileMap[i][j].water_cube)

# Draws all of the individual cubes in the map space
func _draw():
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			Global.tileMap[i][j].water_cube.update()
