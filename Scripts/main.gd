extends Node2D

var map_data : Array = []
@onready var level = $Label
@onready var player = $Player

func _ready():
	Globals.initialize_randomness()
	print("Using seed: ", Globals.rng_seed)
	generate_map()
	render_map()

func generate_map():
	map_data.clear()
	for y in range(Globals.map_height):
		var row = []
		for x in range(Globals.map_width):
			row.append(Constants.FLOOR)
		map_data.append(row)
	position = Vector2(Globals.map_width / 2, Globals.map_height / 2)
	map_data[position.y][position.x] = Constants.PLAYER
	player.position = position;

func render_map():
	var map_str = ""
	for y in range(Globals.map_height):
		for x in range(Globals.map_width):
			map_str += map_data[y][x]
		map_str += "\n"
	
	level.text = map_str

func _on_player_move(new_position: Vector2) -> void:
	#check for valid moves, and if its an attack here
	new_position.x = clamp(new_position.x, 0, Globals.map_width-1)
	new_position.y = clamp(new_position.y, 0, Globals.map_height-1)
	
	map_data[player.position.y][player.position.x] = Constants.FLOOR
	player.position = new_position;
	map_data[player.position.y][player.position.x] = Constants.PLAYER
	
	on_action_taken();

func on_action_taken():
	render_map()
