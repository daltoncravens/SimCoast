extends BTLeaf


# Tile base affects value of zone: dirt > rock > sand
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var tile = blackboard.get_data("queue").front()
	var tile_base = tile.base
	var is_dirt = false
	var is_rock = false
	var is_sand = false
	
	match(tile_base):
		Tile.TileBase.DIRT:
			is_dirt = true
		Tile.TileBase.ROCK:
			is_rock = true
		Tile.TileBase.SAND:
			is_sand = true
		_:
			pass
			
	tile.tile_base_dirt = is_dirt
	tile.tile_base_rock = is_rock
	tile.tile_base_sand = is_sand
	
	return succeed()
