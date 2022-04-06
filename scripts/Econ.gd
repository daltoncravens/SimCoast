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
	$Money.text = "$" + comma_values(str(money))
	
func collectTaxes():
	var taxProfit = 0
	var mapHeight = Global.mapHeight
	var mapWidth = Global.mapWidth
	for i in mapHeight:
		for j in mapWidth:
			var currTile = Global.tileMap[i][j]
			if currTile.zone == Tile.TileZone.HEAVY_COMMERCIAL || currTile.zone == Tile.TileZone.LIGHT_COMMERCIAL:
				taxProfit += currTile.profitRate * (city_tax_rate + property_tax_rate)
			elif currTile.zone == Tile.TileZone.HEAVY_RESIDENTIAL || currTile.zone == Tile.TileZone.LIGHT_RESIDENTIAL:
				taxProfit += currTile.get * property_tax_rate
	adjust_player_money(taxProfit)
			
	

# Helper Functions
func comma_values(val):
	var pos = val.length() % 3
	var res = ""
	
	for i in range(0, val.length()):
		if i != 0 && i % 3 == pos:
			res += ","
		res += val[i]
	return res
