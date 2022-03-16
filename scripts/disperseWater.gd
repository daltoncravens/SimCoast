extends Node

#Disperse water
func disperse_water():
	#Initially, let's just remove excess water on non-ocean tiles
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			var curr = Global.tileMap[i][j]
			if (curr.is_ocean()):
				continue
			elif (curr.get_water_height() > 0):
				curr.waterHeight -= 0.1
				if (curr.get_water_height() < 0):
					curr.waterHeight = 0
