extends CanvasLayer

var base_values = {
	Tile.TileBase.DIRT: "Dirt",
	Tile.TileBase.ROCK: "Rock",
	Tile.TileBase.SAND: "Sand",
	Tile.TileBase.OCEAN: "Ocean"
}

var zone_values = {	
	Tile.TileZone.NONE: "None",
	Tile.TileZone.LIGHT_RESIDENTIAL: "Light Residential",
	Tile.TileZone.HEAVY_RESIDENTIAL: "Heavy Residential",
	Tile.TileZone.LIGHT_COMMERCIAL: "Light Commercial",
	Tile.TileZone.HEAVY_COMMERCIAL: "Heavy Commercial"
}

var inf_values = {
	Tile.TileInf.NONE: "None",
	Tile.TileInf.ROAD: "Road",
	Tile.TileInf.PARK: "Park",
	Tile.TileInf.BUILDING: "Building"
}

var damage_values = {
	Tile.TileStatus.NONE: "None",
	Tile.TileStatus.LIGHT_DAMAGE: "Light Damage",
	Tile.TileStatus.MEDIUM_DAMAGE: "Medium Damage",
	Tile.TileStatus.HEAVY_DAMAGE: "Heavy Damage"
}

func update_tile_display(i, j):
	var tile = Global.tileMap[i][j]
	$BottomBar/HoverText.text = "(%s, %s)" % [i, j]
	$BottomBar/HoverText.text += "     BASE: %s     HEIGHT: %s" % [base_values[tile.get_base()], tile.get_base_height()]
	if tile.get_zone() != Tile.TileZone.NONE:
		$BottomBar/HoverText.text += "     Zone: %s, Buildings: %s / %s, People: %s / %s, Tile Damage: %s%%, Happiness: %s%%, Tile Value: %s" % [zone_values[tile.get_zone()], tile.data[0], tile.data[1], tile.data[2], tile.data[3], tile.tileDamage*100, tile.happiness, tile.landValue]
		if tile.powered:
			$BottomBar/HoverText.text += "     Power: ON"
		else:
			$BottomBar/HoverText.text += "     Power: OFF"
	elif tile.inf == Tile.TileInf.ROAD:
		if tile.powered:
			$BottomBar/HoverText.text += "     Power: ON"
		else:
			$BottomBar/HoverText.text += "     Power: OFF"

