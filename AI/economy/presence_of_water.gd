extends BTLeaf


const INNER_NEIGHBOR = 0.10
const OUTER_NEIGHBOR = 0.5


# Is the zone near a body of water? If so, value increases
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var tile = blackboard.get_data("queue").front()
	var is_close_water = tile.is_close_water
	var is_far_water = tile.is_far_water
	
	# Checking if this zone is touching a water tile
	if is_close_water == false:
		# Check all inner neighbor tiles to check for water
		var neighbors = [[tile.i-1, tile.j], [tile.i+1, tile.j], [tile.i, tile.j-1], [tile.i, tile.j+1]]
		for n in neighbors:
			if is_valid_tile(n[0], n[1]):
				if Global.tileMap[n[0]][n[1]].base == Tile.TileBase.OCEAN:
					is_close_water = true

	# Checking if this zone is second neighbor to a water tile
	if is_far_water == false:		
		var far_neighbors = [[tile.i-2, tile.j], [tile.i+2, tile.j], [tile.i, tile.j-2], [tile.i, tile.j+2], \
			[tile.i+1, tile.j+1], [tile.i-1, tile.j+1], [tile.i-1, tile.j-1], [tile.i+1, tile.j-1]]
		for n in far_neighbors:
			if is_valid_tile(n[0], n[1]):
				if Global.tileMap[n[0]][n[1]].base == Tile.TileBase.OCEAN:
					is_far_water = true
	
	# update tile variable booleans			
	tile.is_close_water = is_close_water
	tile.is_far_water = is_far_water
						
	return succeed()


# Check to see if these indices are valid tile coordinates
func is_valid_tile(i, j) -> bool:
	if i < 0 || Global.mapWidth <= i:
		return false
	if j < 0 || Global.mapHeight <= j:
		return false
	return true
