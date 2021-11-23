# Global Values
# Acts as a singleton and is loaded first with every other script

extends Node

const MAP_EDGE_BUFFER = 150

const TILE_WIDTH = 64
const TILE_HEIGHT = 32

const MAX_HEIGHT = 30

var mapWidth = 10
var mapHeight = 10

var mapTool = 0
var tileMap = initTileMap()

var seaLevel = 2
var oceanHeight = 0

# Values by Camera2D to rotate camera and VectorMap to draw tiles
var camDirection = 0
var rowRange = range(0, mapWidth, 1)
var colRange = range(0, mapHeight, 1)

func initTileMap():
	var tm = []
	
	for _i in range(mapWidth):
		var row = []
		row.resize(mapHeight)
		tm.append(row)

	for x in mapHeight:
		for y in mapWidth:
			tm[x][y] = Tile.new(x, y, 0, 0, 0, 0, 0)
	
	return tm

# Map Tool Buttons to use for setting map tool
enum Tool {
	BASE_DIRT,
	BASE_ROCK,
	BASE_SAND,
	BASE_OCEAN,
	ZONE_LT_RES,
	ZONE_HV_RES,
	ADD_RES_BLDG,
	ADD_RES_PERSON,
	ZONE_LT_COM,
	ZONE_HV_COM,
	ADD_COM_BLDG,
	ADD_COM_PERSON,
	INF_PARK,
	INF_ROAD,
	CLEAR,
	LAYER_WATER
}
