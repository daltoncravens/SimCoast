extends Label

var time = 0;
var time_lapse = 0;
var time_on = false;

var gameSpeed = 5000;
var gameTime = _parse_date(OS.get_datetime() );
var elapsedGameTime;




# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.




func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
