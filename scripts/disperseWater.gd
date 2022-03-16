extends Node

#Percentage of water that a tile will lose 
const WATER_DECREASE_RATE = 0.3 #Can become a member of Tile so that different tiles have different rates of dispersion?
const WATER_THRESHOLD = 0.1 #water below this threshold dissipate without dispersing

#Disperse water, code is based upon John's updateOceanHeight function in City.gd
func disperse_water():
	# 2D array to keep track of which map tiles have been checked
	var visited = []
	for x in range(Global.mapWidth):
		visited.append([])
		for _y in range(Global.mapHeight):
			visited[x].append(0)
	
	# Only tiles that have changes to water values are placed in queue
	var queue = []
	
	# Add non-ocean tiles with water on them to queue
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			if !Global.tileMap[i][j].is_ocean() && Global.tileMap[i][j].get_water_height() > 0:
				visited[i][j] = 1
				queue.append(Global.tileMap[i][j])
	
	# For each tile in queue, drop water height, then distribute that water to neighbors if they are shorter
	while !queue.empty():
		var tile = queue.pop_front()
		
		var mainTileHeight = tile.baseHeight + tile.waterHeight

		# Decrease water height
		tile.waterHeight -= tile.waterHeight * WATER_DECREASE_RATE
		# If under threshold, decrease to zero and skip checking neighbors
		if tile.waterHeight < WATER_THRESHOLD:
			tile.waterHeight = 0
			continue
		
		# Check each orthogonal neighbor to see if water will move to them
		var neighbors = [[tile.i-1, tile.j], [tile.i+1, tile.j], [tile.i, tile.j-1], [tile.i, tile.j+1]]
		for n in neighbors:
			if City.is_tile_inbounds(n[0], n[1]) && visited[n[0]][n[1]] == 0:
				visited[n[0]][n[1]] = 1
				
				var neighborTileHeight =  Global.tileMap[n[0]][n[1]].baseHeight + Global.tileMap[n[0]][n[1]].waterHeight
				
				#If neighbor is lower, distribute water
				if neighborTileHeight < mainTileHeight:
					Global.tileMap[n[0]][n[1]].waterHeight += (tile.waterHeight * WATER_DECREASE_RATE)
	
	queue.clear()
	visited.clear()
