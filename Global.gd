# Global Values
# Acts as a singleton and is loaded first with every other script

extends Node

const MAP_EDGE_BUFFER = 150

const TILE_WIDTH = 64
const TILE_HEIGHT = 32

const MAX_HEIGHT = 20

var mapWidth = 10
var mapHeight = 10

var mapTool = 0
var tileMap = initTileMap()

var oceanLevel = 8

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
			tm[x][y] = Tile.new(x, y)
	
	return tm

# Colors for each type of tile cube (Top/Left/Right/Outline)
const DIRT = [Color("ffc59d76"), Color("ffbb8d5d"), Color("ff9e7758"), Color("ff666666")]
const SAND = [Color("ffd9d3bf"), Color("ffc9bf99"), Color("ffaca075"), Color("ff867d5e")]
const WATER = [Color("ff9cd5e2"), Color("ff8bc4d1"), Color("ff83bcc9"), Color("ff5b8c97")]

const R_ZONE = [Color("ffbcd398"), Color("ffbb8d5d"), Color("ff9e7758"), Color("ff60822d")]
const C_ZONE = [Color("ff7797e2"), Color("ffbb8d5d"), Color("ff9e7758"), Color("ff1d346a")]
const I_ZONE = [Color("ffe6de65"), Color("ffbb8d5d"), Color("ff9e7758"), Color("ff938b0e")]

const ROAD = [Color("ff6a6a6a"), Color("ffbb8d5d"), Color("ff9e7758"), Color("ff999999")]
const PARK = [Color("ff8bb54a"), Color("ffbb8d5d"), Color("ff9e7758"), Color("ff60822d")]
