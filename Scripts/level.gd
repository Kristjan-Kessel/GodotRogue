extends Node2D

var map_data : Array = []

func _ready():
	generate_map()
	render_map()

func generate_map():
	map_data.clear()
	for y in range(Globals.map_height):
		var row = []
		for x in range(Globals.map_width):
			row.append(Constants.FLOOR)
		map_data.append(row)
	map_data[Globals.map_height/2][Globals.map_width/2] = Constants.PLAYER


func render_map():
	var map_str = ""
	for y in range(Globals.map_height):
		for x in range(Globals.map_width):
			map_str += map_data[y][x]
		map_str += "\n"
	
	var label = get_node("MapLabel")
	label.text = map_str
