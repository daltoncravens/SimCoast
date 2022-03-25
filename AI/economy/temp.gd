extends BTLeaf


# (Optional) Do something BEFORE tick result is returned.
func _pre_tick(agent: Node, blackboard: Blackboard) -> void:
	pass


func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var queue = blackboard.get_data("queue")
	if (queue.size() == 0):
		return fail()
	else:
		var num = queue.front()
		agent.Label = "Just kidding!"
		return succeed()

# (Optional) Do something AFTER tick result is returned.
func _post_tick(agent: Node, blackboard: Blackboard, result: bool) -> void:
	var queue = blackboard.get_data("queue")
	queue.remove(0)
	blackboard.set_data("queue", queue)
