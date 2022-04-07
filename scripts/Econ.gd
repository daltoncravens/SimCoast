extends Node

# Stores all global constants/functions relative to the economy implemented (Ex: land value, tile durability...)

const TILE_BASE_VALUE = 500
const BUILDING_BASE_VALUE = 50
const RESIDENT_PERSON_VALUE = 2000
const BASE_TAX_RATE = 0.07 # 7% 


# Tile Durability Constants
const REMOVE_BUILDING_DAMAGE = 0.2
const REMOVE_COMMERCIAL_BUILDING  = 0.3



# Player/Mayor Constants
var money = 100000
# Sales Tax
var city_tax_rate = BASE_TAX_RATE
var city_income = 0 # Net Profit
# Property Tax
var property_tax_rate = 0.01 

# adjustVal parameter takes in the exact amount loss or gain towards the player money 
# EX: if player spends $500 then adjustVal should be -500
func adjust_player_money(adjustVal):
	money += adjustVal
	get_node("/root/CityMap/HUD/TopBar/HBoxContainer/Money").text = "$" + comma_values(str(money))
	
func adjust_city_income(val):
	city_income = val
	get_node("/root/CityMap/HUD/TopBar/HBoxContainer/City_Income").text = "$" + comma_values(str(city_income))
	print("$" + comma_values(str(city_income)))
	
func collectTaxes():
	var taxProfit = 0
	var mapHeight = Global.mapHeight
	var mapWidth = Global.mapWidth
	for i in mapHeight:
		for j in mapWidth:
			var currTile = Global.tileMap[i][j]
			if currTile.zone == Tile.TileZone.HEAVY_COMMERCIAL || currTile.zone == Tile.TileZone.LIGHT_COMMERCIAL:
				taxProfit += (currTile.profitRate * city_tax_rate) + (currTile.data[0] * property_tax_rate)
			elif currTile.zone == Tile.TileZone.HEAVY_RESIDENTIAL || currTile.zone == Tile.TileZone.LIGHT_RESIDENTIAL:
				taxProfit += currTile.data[0] * property_tax_rate
	adjust_player_money(taxProfit)
	
func calcCityIncome():
	var numOfZones = 0
	var totalIncome = 0
	var mapHeight = Global.mapHeight
	var mapWidth = Global.mapWidth
	for i in mapHeight:
		for j in mapWidth:
			var currTile = Global.tileMap[i][j]
			if currTile.zone == Tile.TileZone.HEAVY_COMMERCIAL || currTile.zone == Tile.TileZone.LIGHT_COMMERCIAL:
				totalIncome += currTile.profitRate
				numOfZones += 1
	var avgIncome = 0
	if numOfZones != 0:
		avgIncome = totalIncome / numOfZones
	adjust_city_income(avgIncome)
	return avgIncome
	

# Helper Functions
func comma_values(val):
	var pos = val.length() % 3
	var res = ""
	
	for i in range(0, val.length()):
		if i != 0 && i % 3 == pos:
			res += ","
		res += val[i]
	return res
