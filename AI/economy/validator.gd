extends BTLeaf


const UPPER_LIMIT = 99
const LOWER_LIMIT = 1


# Now that the tile's value has been modified, check if it's valid
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var tile = blackboard.get_data("queue").pop_front()
	
	# Check value validity
	if tile.landvalue < LOWER_LIMIT:
		tile.landvalue = LOWER_LIMIT
	elif tile.landvalue > UPPER_LIMIT:
		tile.landvalue = UPPER_LIMIT	
	
	check_empty(blackboard)
	
	return succeed()


# Checks to see if the last item in the queue was consumed. Stops the AI
func check_empty(blackboard: Blackboard) -> void:
	var empty = blackboard.get_data("queue").empty()
	if empty:
		blackboard.set_data("queue_empty", true)
