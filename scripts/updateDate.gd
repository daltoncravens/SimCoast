extends Node

const MONTH_TICKS = 100
var ticksSinceLastMonthChange = 0

enum Months {
	January,
	February,
	March,
	April,
	May,
	June,
	July,
	August,
	September,
	October,
	November,
	December
}

var month = Months.April
var year = 2022

func update_date():
	ticksSinceLastMonthChange += 1
	if (ticksSinceLastMonthChange >= MONTH_TICKS):
		ticksSinceLastMonthChange = 0
		if (month == Months.December):
			month = Months.January
			year += 1
		else:
			month += 1
		update_month_display()
		Econ.profit()

func update_month_display():
	get_node("/root/CityMap/HUD/Date/Month").text = Months.keys()[month]
	get_node("/root/CityMap/HUD/Date/Year").text = str(year)
