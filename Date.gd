extends Label

var time = 0;
var time_lapse = 0;
var time_on = false;

var gameSpeed = 5000;
var gameTime = _parse_date(OS.get_datetime() );
var elapsedGameTime;

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
