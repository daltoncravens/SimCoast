extends Node


# Need to test to see if this AI is appropriate as a singleton or a child node


# Sets up primary blackboard values
func _ready():
	$Blackboard.set_data("queue", [])
	$Blackboard.set_data("queue_empty", true)


# Checks if the AI's tile queue is empty
func _process(delta):
	if $Blackboard.get_data("queue_empty") == true:
		update_AI()
	

# Obtains a new tile queue and sets it in the blackboard	
func update_AI():
	var latest = update_queue()
	$Blackboard.set_data("queue", latest)
	$Blackboard.set_data("queue_empty", false)
	

# Refills the zone queue
func update_queue() -> Array:
	# Because the map is scalable, update map dimensions
	var mapHeight = Global.mapHeight
	var mapWidth = Global.mapWidth
	var latest = []
	for i in mapHeight:
		for j in mapHeight:
			var current = Global.tileMap[i][j]
			var accept		
			# Check tile zone type. If it's zoned, accept the tile into the queue
			match(current.zone):
				Tile.TileZone.LIGHT_RESIDENTIAL:
					accept = true
				Tile.TileZone.HEAVY_RESIDENTIAL:
					accept = true
				Tile.TileZone.LIGHT_COMMERCIAL:
					accept = true
				Tile.TileZone.HEAVY_COMMERCIAL:
					accept = true
				_:
					accept = false	
			# Check tile infrastructure if not zoned (roads & powerplants)
			if accept != true:
				match(current.inf):
					Tile.TileInf.ROAD:
						accept = true
					Tile.TileInf.PARK:
						accept = true
					Tile.TileInf.POWER_PLANT:
						accept = true
					_:
						accept = false
			if accept:
				latest.push_back(current)
	return latest










