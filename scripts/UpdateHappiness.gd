extends Node

const BASE_HAPPINESS = 50

func update_happiness():
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			if (Global.tileMap[i][j].is_zoned() && Global.tileMap[i][j].data[2] != 0):
				var currTile = Global.tileMap[i][j]
				var happiness = BASE_HAPPINESS
				
				var waterValue = UpdateValue.calc_presence_of_water(currTile)
				var zoneConnectionsValue = UpdateValue.calc_zone_connections(currTile)
				var tileDamageValue = UpdateValue.calc_tile_damage(currTile)
				var taxRateValue = UpdateValue.calc_taxation_rate(currTile)
				
				happiness = happiness + waterValue + zoneConnectionsValue + taxRateValue - tileDamageValue
				
				if happiness < 0:
					happiness = 0
				elif happiness > 100:
					happiness = 100
					
				currTile.happiness = happiness
