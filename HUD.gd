extends CanvasLayer

func update_tile_display(i, j, baseHeight, waterHeight):
	$StatusBar/TileDisplay.text = "Tile: (%s, %s), Base Height: %s, Water Height: %s" % [i, j, baseHeight, waterHeight]

func update_ocean_display():
	$StatueBar/OceanHeight.text = "Ocean Height: %s" % Global.oceanHeight

func update_mouse(pos):
	$StatusBar/MousePosition.text = "Mouse Position: (%s, %s)" % [pos.x, pos.y]

func update_time(date):
	$Date.text = "Date: %s" % "{month}-{day}-{year}".format ({
		month = str(date.month).pad_zeros(2),
		day = str(date.day).pad_zeros(2),
		year = str(date.year).pad_zeros(2)
		})
