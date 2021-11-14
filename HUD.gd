extends CanvasLayer

func update_tile_display(i, j, baseHeight, waterHeight):
	$MarginContainer/TileDisplay.text = "Tile: (%s, %s), Base Height: %s, Water Height: %s" % [i, j, baseHeight, waterHeight]

func update_ocean_display():
	$MarginContainer/OceanHeight.text = "Ocean Height: %s" % Global.oceanHeight

func update_mouse(pos):
	$MarginContainer/MousePosition.text = "Mouse Position: (%s, %s)" % [pos.x, pos.y]
