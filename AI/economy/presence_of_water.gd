extends BTLeaf


const INNER_NEIGHBOR = 10
const OUTER_NEIGHBOR = 5


# Is the zone near a body of water? If so, value increases
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var is_close_to_water = false
	var is_far_to_water = false
	var tile = blackboard.get_data("queue").front()
	
	# Check all inner neighbor tiles to check for water
	var neighbors = [[tile.i-1, tile.j], [tile.i+1, tile.j], [tile.i, tile.j-1], [tile.i, tile.j+1]]
	for n in neighbors:
		if is_valid_tile(n[0], n[1]):
			pass
		if Global.tileMap[n[0]][n[1]].base == Tile.TileBase.OCEAN:
			is_close_to_water = true

	# If tile is not touching water, check second neighbors for water
	if is_close_to_water == false:		
		var far_neighbors = [[tile.i-2, tile.j], [tile.i+2, tile.j], [tile.i, tile.j-2], [tile.i, tile.j+2]]
		for n in far_neighbors:
			if is_valid_tile(n[0], n[1]):
				pass
			if Global.tileMap[n[0]][n[1]].base == Tile.TileBase.OCEAN:
				is_far_to_water = true
	
	# Based on priority, modify tile value			
	if is_close_to_water:
		tile.landvalue += INNER_NEIGHBOR
	elif is_far_to_water:
		tile.landvalue += OUTER_NEIGHBOR
						
	return succeed()


# Check to see if these indices are valid tile coordinates
func is_valid_tile(i, j) -> bool:
	if i < 0 || Global.mapWidth <= i:
		return false
	if j < 0 || Global.mapHeight <= j:
		return false
	return true
