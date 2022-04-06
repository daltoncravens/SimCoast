extends BTLeaf


# Based on percentages
const UPPER_LIMIT = 0.99
const LOWER_LIMIT = 0.1


# Now that the tile's variable coefficients have been updated, update desirability
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var tile = blackboard.get_data("queue").pop_front()
	
	# Equation for calculating desirability
	var desirability = tile.BASE_DESIRABILITY + \
		int(tile.is_close_water) * tile.WATER_CLOSE + \
		int(tile.is_far_water) * tile.WATER_FAR
		
	if desirability > UPPER_LIMIT:
		desirability = UPPER_LIMIT
	elif desirability < LOWER_LIMIT:
		desirability = LOWER_LIMIT
		
	tile.desirability = desirability
	
	check_empty(blackboard)
	
	return succeed()


# Checks to see if the last item in the queue was consumed. Stops the AI
func check_empty(blackboard: Blackboard) -> void:
	var empty = blackboard.get_data("queue").empty()
	if empty:
		blackboard.set_data("queue_empty", true)
