extends BTLeaf

const ZONE_CAP = 30
const PEOPLE_CAP = 100


# How developed is the city in terms of number of zones and population number?
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var tile = blackboard.get_data("queue").front()
	var numZones = 0
	var numPeople = 0
	
	# Count number of zones and people
	for i in Global.mapHeight:
		for j in Global.mapWidth:
			var current = Global.tileMap[i][j]
			if current.zone != Tile.TileZone.NONE:
				numZones += 1
				numPeople += current.data[2]
	
	# Cap the counted values as needed	
	if numZones > ZONE_CAP:
		numZones = ZONE_CAP
	if numPeople > PEOPLE_CAP:
		numPeople = PEOPLE_CAP
	
	# Set the associated Global values
	Global.numZones = numZones
	Global.numPeople = numPeople
	
	return succeed()
