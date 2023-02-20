extends Node

const BASE_TILE_VALUE = 5 #How valuable is an empty plot of land?
const GLOBAL_TILE_VALUE_WEIGHT = 20 #Divide calculated value by this number

const WATER_TILE_WEIGHT = 5

const BASE_DIRT_VALUE = 0
const BASE_SAND_VALUE = -10
const BASE_ROCK_VALUE = -10

const LIGHT_RES_VALUE = 1
const HEAVY_RES_VALUE = 1
const LIGHT_COM_VALUE = 1
const HEAVY_COM_VALUE = -1
const POWER_PLANT_VALUE = -10
const PARK_VALUE = 3
const ROAD_VALUE = 0

const ZONE_VALUE = 0.1

const PERSON_VALUE = 0.1

const TILE_DAMAGE_WEIGHT = -1

const CITY_WEALTH_WEIGHT = 0.001

const TAX_WEIGHT = -100

func update_land_value():
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			if (Global.tileMap[i][j].is_zoned()):
				var currTile = Global.tileMap[i][j]
				var value = BASE_TILE_VALUE
				
				var waterValue = calc_presence_of_water(currTile)
				var baseValue = calc_tile_base(currTile)
				var zoneConnectionsValue = calc_zone_connections(currTile)
				var numZonesValue = calc_num_zones(currTile)
				var numPeopleValue = calc_num_people(currTile)
				var tileDamageValue = calc_tile_damage(currTile)
				var cityWealthValue = calc_city_wealth(currTile)
				var taxRateValue = calc_taxation_rate(currTile)
				
				value += waterValue + baseValue + zoneConnectionsValue + numZonesValue + numPeopleValue - tileDamageValue + cityWealthValue + taxRateValue
				value = value / GLOBAL_TILE_VALUE_WEIGHT
				currTile.landValue = value

func calc_presence_of_water(tile): #Return value of nearby water tiles within a radius
	var numWaterTiles = 0
	var neighbors = [[tile.i-1, tile.j], [tile.i+1, tile.j], [tile.i, tile.j-1], [tile.i, tile.j+1], \
					[tile.i-2, tile.j], [tile.i+2, tile.j], [tile.i, tile.j-2], [tile.i, tile.j+2], \
					[tile.i+1, tile.j+1], [tile.i-1, tile.j+1], [tile.i-1, tile.j-1], [tile.i+1, tile.j-1]]
	
	for n in neighbors:
			if is_valid_tile(n[0], n[1]):
				if Global.tileMap[n[0]][n[1]].base == Tile.TileBase.OCEAN:
					numWaterTiles += 1
	
	return numWaterTiles * WATER_TILE_WEIGHT

func calc_tile_base(tile): #Return value of tiles' base type
	var tile_base = tile.base
	match(tile_base):
		Tile.TileBase.DIRT:
			return BASE_DIRT_VALUE
		Tile.TileBase.ROCK:
			return BASE_ROCK_VALUE
		Tile.TileBase.SAND:
			return BASE_ROCK_VALUE
		_:
			pass
	return

func calc_zone_connections(tile): #Return final value of the tiles surrounding selected tile
	var neighbors = [[tile.i-1, tile.j], [tile.i+1, tile.j], [tile.i, tile.j-1], [tile.i, tile.j+1],
			[tile.i-2, tile.j], [tile.i+2, tile.j], [tile.i, tile.j-2], [tile.i, tile.j+2],
			[tile.i+1, tile.j+1], [tile.i-1, tile.j+1], [tile.i-1, tile.j-1], [tile.i+1, tile.j-1]]
	
	var light_residential_neighbor = 0
	var heavy_residential_neighbor = 0
	var light_commercial_neighbor = 0
	var heavy_commercial_neighbor = 0
	var industrial_neighbor = 0
	var park_neighbor = 0
	var road_neighbor = 0
	
	for n in neighbors:
		if is_valid_tile(n[0], n[1]):
			# Check if it's a powerplant
			if Global.tileMap[n[0]][n[1]].inf == Tile.TileInf.POWER_PLANT:
				industrial_neighbor += 1
				continue
			elif Global.tileMap[n[0]][n[1]].inf == Tile.TileInf.PARK:
				park_neighbor += 1
				continue
			elif Global.tileMap[n[0]][n[1]].inf == Tile.TileInf.ROAD:
				road_neighbor += 1
				continue
			
			# Check what type of zone the neighbor is
			var neighbor = Global.tileMap[n[0]][n[1]]
			match(neighbor.zone):
				Tile.TileZone.LIGHT_RESIDENTIAL:
					light_residential_neighbor += 1
				Tile.TileZone.HEAVY_RESIDENTIAL:
					heavy_residential_neighbor += 1
				Tile.TileZone.LIGHT_COMMERCIAL:
					light_commercial_neighbor += 1
				Tile.TileZone.HEAVY_COMMERCIAL:
					heavy_commercial_neighbor += 1
				_:
					continue
	
	return (LIGHT_RES_VALUE * light_residential_neighbor) + \
			(HEAVY_RES_VALUE * heavy_residential_neighbor) + \
			(LIGHT_COM_VALUE* light_commercial_neighbor) + \
			(HEAVY_COM_VALUE * heavy_commercial_neighbor) + \
			(POWER_PLANT_VALUE * industrial_neighbor) + \
			(PARK_VALUE * park_neighbor) + \
			(ROAD_VALUE * road_neighbor)

func calc_num_zones(tile): #Return value number of zones in city
	var numZones = 0
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			var current = Global.tileMap[i][j]
			if current.zone != Tile.TileZone.NONE:
				numZones += 1
	return ZONE_VALUE * numZones

func  calc_num_people(tile): #Return value of number of people in city
	return UpdatePopulation.TOTAL_POPULATION * PERSON_VALUE

func calc_tile_damage(tile): #Return a value depending on tile damage
	#this returns a value that represents the percentage of damage a tile has
	#this limits happiness to, at most, 100 - the damage of the tile.
	#introducing a cap to happiness that is proportional to damage of the tile
	return tile.tileDamage * 100 #1 is max tile health, so *100 is percentiles

func calc_city_wealth(tile): #Return a value based on city wealth
	var cityWealthValue = 0
	cityWealthValue = Econ.money * CITY_WEALTH_WEIGHT #TODO: Make this logarithmic?
	return cityWealthValue

func calc_taxation_rate(tile): #Return a weight depending on tax rate of tile
	var cityTaxValue = 0
	
	match(tile.zone):
		Tile.TileZone.LIGHT_RESIDENTIAL:
			cityTaxValue = Econ.LIGHT_RES_PROPERTY_RATE + Econ.LIGHT_RES_PROPERTY_RATE
		Tile.TileZone.HEAVY_RESIDENTIAL:
			cityTaxValue = Econ.HEAVY_RES_PROPERTY_RATE + Econ.HEAVY_RES_PROPERTY_RATE
		Tile.TileZone.LIGHT_COMMERCIAL:
			cityTaxValue = Econ.LIGHT_COM_PROPERTY_RATE + Econ.LIGHT_COM_PROPERTY_RATE
		Tile.TileZone.HEAVY_COMMERCIAL:
			cityTaxValue = Econ.HEAVY_COM_PROPERTY_RATE + Econ.HEAVY_COM_PROPERTY_RATE
	
	cityTaxValue = cityTaxValue * TAX_WEIGHT
	return cityTaxValue

func is_valid_tile(i, j) -> bool: # Check to see if these indices are valid tile coordinates
	if i < 0 || Global.mapWidth <= i:
		return false
	if j < 0 || Global.mapHeight <= j:
		return false
	return true
