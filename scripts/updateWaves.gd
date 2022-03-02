extends Node

#temp var for ocean level directions
var waterDir = 1

#Update waves
func update_waves():
	Global.oceanHeight += (Global.waveStrength * waterDir)
	City.updateOceanHeight(waterDir);
	if Global.oceanHeight <= Global.baseOceanHeight || Global.oceanHeight >= Global.baseOceanHeight + Global.waveHeight:
		waterDir *= -1
