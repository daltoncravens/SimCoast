extends Node

func update_erosion():
	var mapHeight = Global.mapHeight
	var mapWidth = Global.mapWidth

	for i in mapHeight:
		for j in mapWidth:
			var currTile = Global.tileMap[i][j]
			if currTile.base != Tile.TileBase.OCEAN:
				var waterPresence = calc_water_neighbors(currTile)
				if currTile.base == Tile.TileBase.DIRT:
					currTile.erosion += 0.01 * waterPresence
				elif currTile.base == Tile.TileBase.ROCK:
					currTile.erosion += 0.005 * waterPresence
				elif currTile.base == Tile.TileBase.SAND:
					currTile.erosion += 0.02 * waterPresence
			# if tile reaches max erosion, reduce height of tile and reset
			if currTile.erosion >= 100:
				currTile.erosion = 0
				currTile.baseHeight -= 1
func calc_water_neighbors(tile):
	# check 8 adjacent tiles for water
	var numWaterTiles = 0
	var neighbors = [[tile.i-1, tile.j], [tile.i+1, tile.j], [tile.i, tile.j-1], [tile.i, tile.j+1], \
					[tile.i+1, tile.j+1], [tile.i-1, tile.j+1], [tile.i-1, tile.j-1], [tile.i+1, tile.j-1]]
	for n in neighbors:
			if UpdateValue.is_valid_tile(n[0], n[1]):
				# if the adjecent tiles are an ocean tile
				# or their waterHeight has exceeded their baseHeight (tile is flooded) proc erosion
				if Global.tileMap[n[0]][n[1]].base == Tile.TileBase.OCEAN \
				|| Global.tileMap[n[0]][n[1]].waterHeight > Global.tileMap[n[0]][n[1]].baseHeight:
					numWaterTiles += 1
				
	return numWaterTiles
