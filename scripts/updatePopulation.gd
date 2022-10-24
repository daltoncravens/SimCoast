extends Node

#Constants for determining building, move-ins, and move-outs
#Some of these (such as tile value) should actually be calculated
var BASE_BUILD_CHANCE = 0.01
var BASE_MOVE_CHANCE = 0.01
var BASE_LEAVE_CHANCE = 0.01

var NO_POWER_UNHAPPINESS = 10
var DAMAGE_UNHAPPINESS = 10
var SEVERE_DAMAGE_UNHAPPINESS = 30

var TOTAL_POPULATION = 0
var RESIDENTS = 0
var WORKERS = 0

var rng = RandomNumberGenerator.new()

#Update buildings and population
func update_population():
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			if Global.tileMap[i][j].is_zoned() && Global.tileMap[i][j].is_powered():
				
				rng.randomize()
				if ((BASE_BUILD_CHANCE * Global.tileMap[i][j].desirability) > rng.randf()):
					Global.tileMap[i][j].add_building()
				if ((BASE_MOVE_CHANCE * Global.tileMap[i][j].desirability) > rng.randf()):
					var change = Global.tileMap[i][j].add_people(1)
					#print("add " + str(change))
					TOTAL_POPULATION += change
					
			if Global.tileMap[i][j].has_building():
				
				var leaveChance = 0
				var status = Global.tileMap[i][j].get_status()
				
				if (!Global.tileMap[i][j].is_powered()):
					leaveChance += NO_POWER_UNHAPPINESS 
				if (status == Tile.TileStatus.LIGHT_DAMAGE || status == Tile.TileStatus.MEDIUM_DAMAGE):
					leaveChance += DAMAGE_UNHAPPINESS
				elif (status == Tile.TileStatus.HEAVY_DAMAGE):
					leaveChance += SEVERE_DAMAGE_UNHAPPINESS
				
				rng.randomize()
				if ((BASE_LEAVE_CHANCE * leaveChance * Global.tileMap[i][j].desirability) > rng.randf() && TOTAL_POPULATION > 0):
					var change = Global.tileMap[i][j].remove_people(1)
					#print("remove " + str(change))
					TOTAL_POPULATION += change
	
	get_node("/root/CityMap/HUD/TopBar/HBoxContainer/Population").text = "Total Population: " + str(TOTAL_POPULATION)
					
func get_population():
	return TOTAL_POPULATION
