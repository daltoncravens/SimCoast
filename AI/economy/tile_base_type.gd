extends BTLeaf


# Tile base affects value of zone: sand < rock < dirt
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	return succeed()
