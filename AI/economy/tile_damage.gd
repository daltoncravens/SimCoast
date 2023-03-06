extends BTLeaf


# How damadged is this tile?
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var tile = blackboard.get_data("queue").front()
	if tile.tileDamage <= .2:
		tile.tile_dmg_weight = -0.025
	elif tile.tileDamage <= .4:
		tile.tile_dmg_weight = -0.1
	elif tile.tileDamage <= .6:
		tile.tile_dmg_weight = -0.2
	elif tile.tileDamage <= .8:
		tile.tile_dmg_weight = -0.4
	else:
		tile.tile_dmg_weight = -0.8
	return succeed()
