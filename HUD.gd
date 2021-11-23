extends CanvasLayer

func update_tile_display(i, j, baseHeight, waterHeight):
	if Global.tileMap[int(i)][int(j)].get_zone() != Tile.TileZone.NONE:
		var data = Global.tileMap[int(i)][int(j)].get_data()
		$StatusBar/TileDisplay.text = "Zone: Residential, Buildings: %s / %s, People: %s / %s" % [data[0], data[1], data[2], data[3]]
	else:
		$StatusBar/TileDisplay.text = "Tile: (%s, %s), Base Height: %s, Water Height: %s" % [i, j, baseHeight, waterHeight]

func update_ocean_display():
	$StatusBar/OceanHeight.text = "Ocean Height: %s" % Global.oceanHeight

func update_mouse(pos):
	$StatusBar/MousePosition.text = "Mouse Position: (%s, %s)" % [pos.x, pos.y]

func update_time(date):
	$Date.text = "Date: %s" % "{month}-{year}".format ({
		month = str(date.month).pad_zeros(2),
		year = str(date.year).pad_zeros(2)
		})
