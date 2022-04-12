extends BTLeaf


# Based on percentages
const UPPER_LIMIT = 0.99
const LOWER_LIMIT = 0.01


# Now that the tile's variable coefficients have been updated, update desirability
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var tile = blackboard.get_data("queue").pop_front()
	
	# Equation for calculating desirability
	var desirability = tile.BASE_DESIRABILITY + \
		int(tile.is_close_water) * tile.WATER_CLOSE + \
		int(tile.is_far_water) * tile.WATER_FAR + \
		int(tile.tile_base_dirt) * tile.BASE_DIRT + int(tile.tile_base_rock) * tile.BASE_ROCK + int(tile.tile_base_sand) * tile.BASE_SAND + \
		tile.residential_neighbors * tile.RESIDENTIAL_NEIGHBOR + tile.commercial_neighbors * tile.COMMERCIAL_NEIGHBOR + tile.industrial_neighbors * tile.INDUSTRIAL_NEIGHBOR + \
		Global.numZones * tile.NUMBER_ZONES + Global.numPeople * tile.NUMBER_PEOPLE + \
		int(tile.is_sales_tax_heavy) * tile.SALES_TAX_HEAVY + \
		tile.prop_tax_weight + \
		int(tile.is_neg_profit) * tile.WEALTH_NEG + \
		tile.wealth_weight * tile.WEALTH_DESIRE + \
		tile.tile_dmg_weight
		
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
