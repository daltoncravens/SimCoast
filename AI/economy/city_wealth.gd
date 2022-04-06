extends BTLeaf


# What is the city income? Proportionate to number of zones
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var tile = blackboard.get_data("queue").front()
	var avgIncome = Econ.calcCityIncome()
	if tile.profitRate < 0:
		tile.is_neg_profit = true
	elif tile.profitRate < avgIncome - 1000:
		tile.wealth_weight = 0
	elif avgIncome - 1000 <= tile.profitRate && tile.profitRate < avgIncome:
		tile.wealth_weight = 1
	elif avgIncome <= tile.profitRate && tile.profitRate < avgIncome + 1000:
		tile.wealth_weight = 2
	else:
		tile.wealth_weight = 4
	return succeed()
