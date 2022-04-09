extends BTLeaf


# Because composite nodes need 2+ child nodes, this leaf fulfills that requirement
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	return succeed()
