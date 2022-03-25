extends Node

var mapHeight
var mapWidth


func _ready():
	mapHeight = Global.mapHeight
	mapWidth = Global.mapWidth
	update_queue()


func _process(delta):
	# Because the map is scalable, update map dimensions
	#$Label.text = "Hello script world!"
	#var msg = $Label.text + " How's it going?"
	#$Label.text = msg
	pass


func update_queue():
	var latest = [1,2,3,4,5,6,7,8,9]
	$Blackboard.set_data("queue", latest)
	
