extends TileMap

var width
var height

func setGridSize(x, y):
	width = x
	height = y

# Data contains x, y, and tile index value for each map cell
func setCells(data):
	for cell in data:
		set_cell(cell[0], cell[1], cell[2])
