extends Node

func _ready():
	pass

func saveData(mapPath: String):
	var correctMapName = mapPath.trim_suffix(".json")
	correctMapName = correctMapName.trim_prefix("res://saves/")
	if not (".json" in mapPath):
		mapPath += ".json"
	print(mapPath)
	var tileData = []
			
	for i in Global.mapWidth:
		for j in Global.mapHeight:
			tileData.append(Global.tileMap[i][j].get_save_tile_data())
			
	var data = {
		"name": correctMapName,
		"mapWidth": Global.mapWidth,
		"mapHeight": Global.mapHeight,
		"oceanHeight": Global.oceanHeight,
		"seaLevel": Global.seaLevel,
		"tiles": tileData,
		"money": Econ.money
	}
	
	var file
	file = File.new()
	file.open(mapPath, File.WRITE)
	file.store_line(to_json(data))
	file.close()
	Global.mapPath = mapPath
	return [correctMapName, mapPath]


func loadData(mapPath: String):
	if not (".json" in mapPath):
		return
	var file = File.new()
	if not file.file_exists(mapPath):
		return
	file.open(mapPath, File.READ)
	var mapData = parse_json(file.get_as_text())
	file.close()
	
	Global.mapName = mapData.name
	Global.mapPath = mapPath
	Global.mapWidth = mapData.mapWidth
	Global.mapHeight = mapData.mapHeight
	Global.oceanHeight = mapData.oceanHeight
	Global.seaLevel = mapData.seaLevel
	Econ.money = mapData.money
	
	Global.tileMap.clear()
	
	for _x in range(Global.mapWidth):
		var row = []
		row.resize(Global.mapHeight)
		Global.tileMap.append(row)

	for tileData in mapData.tiles:
		Global.tileMap[tileData[0]][tileData[1]] = Tile.new(int(tileData[0]), int(tileData[1]), int(tileData[2]), int(tileData[3]), int(tileData[4]), int(tileData[5]), int(tileData[6]), tileData[7], int(tileData[8]), int(tileData[9]), int(tileData[10]))
	return mapData.name
