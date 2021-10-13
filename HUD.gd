extends CanvasLayer

func update_tile_display(tile, height):
	$MarginContainer/TileDisplay.text = "Tile: (%s, %s), Base Height: %s" % [tile.x, tile.y, height]

func update_ocean_display():
	$MarginContainer/OceanLevel.text = "Ocean Level: %s" % Global.oceanLevel

func update_mouse(pos):
	$MarginContainer/MousePosition.text = "Mouse Position: (%s, %s)" % [pos.x, pos.y]
