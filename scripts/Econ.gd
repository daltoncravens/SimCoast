extends Node

# Stores all global constants/functions relative to the economy implemented (Ex: land value, tile durability...)

const TILE_BASE_VALUE = 500
const BUILDING_BASE_VALUE = 50
const RESIDENT_PERSON_VALUE = 2000



#tax rates
const TAX_INCOME_MULTIPLIER = 1000
var BASE_TAX_RATE = 0.05 # 5% #TODO: Be able to update this in-game / maybe different tax rates for commercial/residentail/industry
var LIGHT_RES_PROPERTY_RATE = BASE_TAX_RATE #land value * num buildings
var LIGHT_RES_INCOME_RATE = BASE_TAX_RATE #land value * num people
var HEAVY_RES_PROPERTY_RATE = BASE_TAX_RATE #land value * num people
var HEAVY_RES_INCOME_RATE = BASE_TAX_RATE #land value * num people
var LIGHT_COM_PROPERTY_RATE = BASE_TAX_RATE #land value * num people
var LIGHT_COM_INCOME_RATE = BASE_TAX_RATE #land value * num people
var HEAVY_COM_PROPERTY_RATE = BASE_TAX_RATE #land value * num people
var HEAVY_COM_INCOME_RATE = BASE_TAX_RATE #land value * num people

# Tile Durability Constants
const REMOVE_BUILDING_DAMAGE = 0.2
const REMOVE_COMMERCIAL_BUILDING  = 0.3

#Building costs
const POWER_PLANT_COST = 10000
const PARK_COST = 500
const ROAD_COST = 100

#Building upkeep costs
const POWER_PLANT_UPKEEP_COST = 100
const PARK_UPKEEP_COST = 10
const ROAD_UPKEEP_COST = 2

# Player/Mayor Constants
var money = 100000

#Income and costs
var city_income = 0 # Net Profit
var city_costs = 0 # Upkeep costs

#Probably not needed
var city_tax_rate = BASE_TAX_RATE
var property_tax_rate = 0.01 


# adjustVal parameter takes in the exact amount loss or gain towards the player money 
# EX: if player spends $500 then adjustVal should be -500
func adjust_player_money(adjustVal):
	money += adjustVal
	get_node("/root/CityMap/HUD/TopBar/HBoxContainer/Money").text = "$" + comma_values(str(money))

func purchase_structure(structureCost):
	if ((money - structureCost) >= 0):
		money -= structureCost
		get_node("/root/CityMap/HUD/TopBar/HBoxContainer/Money").text = "$" + comma_values(str(money))
		return true
	else:
		return false

func calculate_upkeep_costs():
	city_costs = ((City.numPowerPlants * POWER_PLANT_UPKEEP_COST) + (City.numParks * PARK_UPKEEP_COST) + (City.numRoads * ROAD_UPKEEP_COST))

#func adjust_city_income(val):
#	city_income = val
#	get_node("/root/CityMap/HUD/TopBar/HBoxContainer/City_Income").text = "$" + comma_values(str(city_income))
#	print("$" + comma_values(str(city_income)))
	
func updateProfitDisplay():
	var profit = round(city_income - city_costs)
	get_node("/root/CityMap/HUD/TopBar/HBoxContainer/City_Income").text = "$" + comma_values(str(profit))
	#print("$" + comma_values(str(profit)))
	
func profit():
	var profit = round(city_income - city_costs)
	adjust_player_money(profit)

func collectTaxes():
	var taxProfit = 0
	var mapHeight = Global.mapHeight
	var mapWidth = Global.mapWidth
	for i in mapHeight:
		for j in mapWidth:
			var currTile = Global.tileMap[i][j]
			if currTile.zone == Tile.TileZone.HEAVY_COMMERCIAL:
				taxProfit += (currTile.data[2] * HEAVY_COM_INCOME_RATE * currTile.landValue) #multiplied by some profit rate
				taxProfit += (currTile.data[0] * HEAVY_COM_PROPERTY_RATE * currTile.landValue) #multiplied by some land value
			elif currTile.zone == Tile.TileZone.LIGHT_COMMERCIAL:
				taxProfit += (currTile.data[2] * LIGHT_COM_INCOME_RATE * currTile.landValue) #multiplied by some profit rate
				taxProfit += (currTile.data[0] * LIGHT_COM_PROPERTY_RATE * currTile.landValue) #multiplied by some land value
			elif currTile.zone == Tile.TileZone.HEAVY_RESIDENTIAL:
				taxProfit += (currTile.data[2] * HEAVY_RES_INCOME_RATE * currTile.landValue) #multiplied by some profit rate
				taxProfit += (currTile.data[0] * HEAVY_RES_PROPERTY_RATE * currTile.landValue) #multiplied by some land value
			elif currTile.zone == Tile.TileZone.LIGHT_RESIDENTIAL:
				taxProfit += (currTile.data[2] * LIGHT_RES_INCOME_RATE * currTile.landValue) #multiplied by some profit rate
				taxProfit += (currTile.data[0] * LIGHT_RES_PROPERTY_RATE * currTile.landValue) #multiplied by some land value
	adjust_player_money(round(taxProfit))
	
func calcCityIncome(): #Calculate tax profit
	var taxProfit = 0
	var mapHeight = Global.mapHeight
	var mapWidth = Global.mapWidth
	for i in mapHeight:
		for j in mapWidth:
			var currTile = Global.tileMap[i][j]
			if currTile.zone == Tile.TileZone.HEAVY_COMMERCIAL:
				taxProfit += (currTile.data[2]  * currTile.landValue * HEAVY_COM_INCOME_RATE * TAX_INCOME_MULTIPLIER) #multiplied by some profit rate
				taxProfit += (currTile.data[0]  * currTile.landValue * HEAVY_COM_PROPERTY_RATE * TAX_INCOME_MULTIPLIER) #multiplied by some land value
			elif currTile.zone == Tile.TileZone.LIGHT_COMMERCIAL:
				taxProfit += (currTile.data[2]  * currTile.landValue * LIGHT_COM_INCOME_RATE * TAX_INCOME_MULTIPLIER) #multiplied by some profit rate
				taxProfit += (currTile.data[0]  * currTile.landValue * LIGHT_COM_PROPERTY_RATE * TAX_INCOME_MULTIPLIER) #multiplied by some land value
			elif currTile.zone == Tile.TileZone.HEAVY_RESIDENTIAL:
				taxProfit += (currTile.data[2]  * currTile.landValue * HEAVY_RES_INCOME_RATE * TAX_INCOME_MULTIPLIER) #multiplied by some profit rate
				taxProfit += (currTile.data[0]  * currTile.landValue * HEAVY_RES_PROPERTY_RATE * TAX_INCOME_MULTIPLIER) #multiplied by some land value
			elif currTile.zone == Tile.TileZone.LIGHT_RESIDENTIAL:
				taxProfit += (currTile.data[2]  * currTile.landValue * LIGHT_RES_INCOME_RATE * TAX_INCOME_MULTIPLIER) #multiplied by some profit rate
				taxProfit += (currTile.data[0]  * currTile.landValue * LIGHT_RES_PROPERTY_RATE * TAX_INCOME_MULTIPLIER) #multiplied by some land value
	city_income = taxProfit
	return round(taxProfit)
	
	#var numOfZones = 0
	#var totalIncome = 0
	#var mapHeight = Global.mapHeight
	#var mapWidth = Global.mapWidth
	#for i in mapHeight:
	#	for j in mapWidth:
	#		var currTile = Global.tileMap[i][j]
	#		if currTile.zone == Tile.TileZone.HEAVY_COMMERCIAL || currTile.zone == Tile.TileZone.LIGHT_COMMERCIAL:
	#			totalIncome += currTile.profitRate
	#			numOfZones += 1
	#var avgIncome = 0
	#if numOfZones != 0:
	#	avgIncome = totalIncome / numOfZones
	#adjust_city_income(avgIncome)
	#return avgIncome

func adjust_tax_rate(val):
	BASE_TAX_RATE += val
	if (BASE_TAX_RATE < 0):
		BASE_TAX_RATE = 0
	elif (BASE_TAX_RATE > 1):
		BASE_TAX_RATE = 1
	get_node("/root/CityMap/HUD/TopBar/HBoxContainer/City_Tax_Rate").text = "Tax Rate: " + str(BASE_TAX_RATE * 100) + "%"

# Helper Functions
func comma_values(val):
	var pos = val.length() % 3
	var res = ""
	
	for i in range(0, val.length()):
		if i != 0 && i % 3 == pos:
			res += ","
		res += val[i]
	return res
