extends Node

#Update graphics
func update_graphics():
	# Update all tiles
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			Global.tileMap[i][j].cube.update()
