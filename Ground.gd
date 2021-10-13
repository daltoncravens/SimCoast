extends TileMap

var width
var height

func setSize(x, y):
	width = x
	height = y

func setCells(data):
	for cell in data:
		set_cell(cell[0], cell[1], cell[2])
