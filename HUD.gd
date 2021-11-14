extends CanvasLayer

func update_tile_display(i, j, height, waterHeight):
	$MarginContainer/TileDisplay.text = "Tile: (%s, %s), Base Height: %s, Water Height: %s" % [i, j, height, waterHeight]

func update_ocean_display():
	$MarginContainer/OceanLevel.text = "Ocean Level: %s" % Global.oceanLevel

func update_mouse(pos):
	$MarginContainer/MousePosition.text = "Mouse Position: (%s, %s)" % [pos.x, pos.y]
