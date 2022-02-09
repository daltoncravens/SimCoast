extends Node

#temp var for ocean level directions
var waterDir = 1

#Update waves
func update_waves():
	if Global.oceanHeight == 0:
			Global.oceanHeight = 1
	Global.oceanHeight += (1 * waterDir)
	City.updateOceanHeight(waterDir);
	if Global.oceanHeight <= 1 || Global.oceanHeight >= 5:
		waterDir *= -1
