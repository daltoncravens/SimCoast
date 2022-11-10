extends Node

var NO_POWER_UNHAPPINESS = 10
var DAMAGE_UNHAPPINESS = 10
var SEVERE_DAMAGE_UNHAPPINESS = 30

func calcResidentialDemand():
	# calc avg happiness of all residential zones
	var mapHeight = Global.mapHeight
	var mapWidth = Global.mapWidth
	
	var resDemand = 0
	var resZones = 0
	var avgleave = 0
	var avgmove = 0
	for i in mapHeight:
		for j in mapWidth:
			var currTile = Global.tileMap[i][j]
			if currTile.zone == Tile.TileZone.LIGHT_RESIDENTIAL || currTile.zone == Tile.TileZone.HEAVY_RESIDENTIAL:
				# calc chance of pop moving in (based on updatePopulation chance)
				avgmove += (currTile.happiness + currTile.landvalue)
				# calc of pop leaving (based on updatePopulation chance)
				if !currTile.is_powered():
					avgleave += NO_POWER_UNHAPPINESS
				elif currTile.get_status() == Tile.TileStatus.LIGHT_DAMAGE || currTile.get_status() == Tile.TileStatus.MEDIUM_DAMAGE:
					avgleave += DAMAGE_UNHAPPINESS
				elif currTile.get_status() == Tile.TileStatus.HEAVY_DAMAGE:
					avgleave += SEVERE_DAMAGE_UNHAPPINESS
				resZones += 1
	avgleave /= resZones
	avgmove /= resZones
	# if more citizens are leaving than moving in, no demand
	if avgleave > avgmove:
		resDemand = 0
	# otherwise scale demand based on the difference between the two
	else:
		resDemand = (avgmove - avgleave)/10
	#print("Residential Demand: " + resDemand)
	return resDemand

func calcCommercialDemand():
	var mapHeight = Global.mapHeight
	var mapWidth = Global.mapWidth
	
	var comDemand = 0
	var pop = 0;
	var comzones = 0;
	# get population and number of commercial zones, Heavy Commercial weighted double 
	for i in mapHeight:
		for j in mapWidth:
			var currTile = Global.tileMap[i][j]
			if currTile.zone == Tile.TileZone.HEAVY_RESIDENTIAL:
				pop += currTile.data[2]
			elif currTile.zone == Tile.TileZone.LIGHT_RESIDENTIAL:
				pop += currTile.data[2]
			elif currTile.zone == Tile.TileZone.HEAVY_COMMERCIAL:
				comzones += 2
			elif currTile.zone == Tile.TileZone.LIGHT_COMMERCIAL:
				comzones += 1
	# for every 48 residential pop (3 full residential zones), demand 1 commercial zone
	comDemand = round(pop/48)
	comDemand -= comzones
	# Don't accept negative demand
	if comDemand < 0:
		comDemand = 0;
	#print("Commercial Demand: " + comDemand)
	return comDemand
