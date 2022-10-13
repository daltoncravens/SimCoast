extends BTLeaf

const avg_property_tax_rate = 0.008
const avg_sales_tax = 0.07
var avg_tax_rate = Econ.BASE_TAX_RATE

# Tax rates change how valuable a zone is through a negative relationship
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var tile = blackboard.get_data("queue").front()
	if avg_property_tax_rate > Econ.property_tax_rate:
		tile.prop_tax_weight = tile.PROP_TAX_LOW
	elif avg_property_tax_rate < Econ.property_tax_rate:
		tile.prop_tax_weight = tile.PROP_TAX_HEAVY
	else:
		tile.prop_tax_weight = 0
	if avg_sales_tax < Econ.city_tax_rate:
		tile.is_sales_tax_heavy = true
	else:
		tile.is_sales_tax_heavy = false
	return succeed()
