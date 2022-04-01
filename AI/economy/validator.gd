extends BTLeaf


# Based on percentages
const UPPER_LIMIT = 0.99
const LOWER_LIMIT = 0.1


# Now that the tile's value has been modified, check if it's valid
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var tile = blackboard.get_data("queue").pop_front()
	
	# Check value validity
	if tile.desirability < LOWER_LIMIT:
		tile.desirability = LOWER_LIMIT
	elif tile.desirability > UPPER_LIMIT:
		tile.desirability = UPPER_LIMIT	
	
	check_empty(blackboard)
	
	return succeed()


# Checks to see if the last item in the queue was consumed. Stops the AI
func check_empty(blackboard: Blackboard) -> void:
	var empty = blackboard.get_data("queue").empty()
	if empty:
		blackboard.set_data("queue_empty", true)
