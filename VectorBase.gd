extends Polygon2D

const DIRT_TOP = Color("ffc59d76")
const DIRT_LEFT_SIDE = Color("ffbb8d5d")
const DIRT_RIGHT_SIDE = Color("ff9e7758")
const DIRT_OUTLINE = Color("ff666666")

# Initialize the map
func _ready():
	for _i in range(Global.mapWidth):
		var row = []
		row.resize(Global.mapHeight)
		Global.tileMap.append(row)
		
	for x in Global.mapHeight:
		for y in Global.mapWidth:
			Global.tileMap[x][y] = Tile.new(x, y)
			set_shape(x, y)

func _draw():
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			draw_cube(i, j)

func redraw_map():
	update()

func set_shape(tile_x, tile_y):
	var x = (tile_x * (Global.TILE_WIDTH / 2.0)) + (tile_y * (-Global.TILE_WIDTH / 2.0))
	var y = (tile_x * (Global.TILE_HEIGHT / 2.0)) + (tile_y * (Global.TILE_HEIGHT / 2.0))
	var h = Global.tileMap[tile_x][tile_y].height
	
	Global.tileMap[tile_x][tile_y].top.set_polygon(PoolVector2Array([Vector2(x, y - h), Vector2(x + (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), 
	Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x - (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0)), Vector2(x, y - h)]))
	
	if h > 0:
		Global.tileMap[tile_x][tile_y].left_side.set_polygon(PoolVector2Array([Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x, y + Global.TILE_HEIGHT), 
		Vector2(x - (Global.TILE_WIDTH / 2.0), y + (Global.TILE_HEIGHT/2.0)), Vector2(x - (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0))]))
	
		Global.tileMap[tile_x][tile_y].right_side.set_polygon(PoolVector2Array([Vector2(x, y - h + Global.TILE_HEIGHT), Vector2(x, y + Global.TILE_HEIGHT), 
		Vector2(x + (Global.TILE_WIDTH / 2.0), y + (Global.TILE_HEIGHT / 2.0)), Vector2(x + (Global.TILE_WIDTH / 2.0), y - h + (Global.TILE_HEIGHT / 2.0))]))

func draw_cube(tile_x, tile_y):
	if Global.tileMap[tile_x][tile_y].height > 0:
		draw_polygon(Global.tileMap[tile_x][tile_y].left_side.get_polygon(), PoolColorArray([DIRT_LEFT_SIDE]))
		draw_polygon(Global.tileMap[tile_x][tile_y].right_side.get_polygon(), PoolColorArray([DIRT_RIGHT_SIDE]))
	draw_polygon(Global.tileMap[tile_x][tile_y].top.get_polygon(), PoolColorArray([DIRT_TOP]))
	draw_polyline(Global.tileMap[tile_x][tile_y].top.get_polygon(), DIRT_OUTLINE)
