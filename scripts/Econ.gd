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
var city_tax_rate = BASE_TAX_RATE
var city_income = 0 # Net Profit

# adjustVal parameter takes in the exact amount loss or gain towards the player money 
# EX: if player spends $500 then adjustVal should be -500
func adjust_player_money(adjustVal):
	money += adjustVal
	$Money.text = "$" + comma_values(str(money))
	

# Helper Functions
func comma_values(val):
	var pos = val.length() % 3
	var res = ""
	
	for i in range(0, val.length()):
		if i != 0 && i % 3 == pos:
			res += ","
		res += val[i]
	return res
