extends BTLeaf


# Tax rates change how valuable a zone is through a negative relationship
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	return succeed()
