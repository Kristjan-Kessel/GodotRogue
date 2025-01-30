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
			row.append(Tile.new("floor", true, Constants.FLOOR))
		map_data.append(row)

	var start_pos = Vector2(Globals.map_width / 2, Globals.map_height / 2)
	map_data[start_pos.y][start_pos.x].entity = player
	player.position = start_pos

func render_map():
	var map_str = ""
	for y in range(Globals.map_height):
		for x in range(Globals.map_width):
			var tile = map_data[y][x]
			if tile.entity == null:
				map_str += tile.ascii
			else:
				map_str += tile.entity.ascii
		map_str += "\n"	
	level.text = map_str

func _on_player_move(new_position: Vector2) -> void:
	new_position.x = clamp(new_position.x, 0, Globals.map_width - 1)
	new_position.y = clamp(new_position.y, 0, Globals.map_height - 1)

	var target_tile = map_data[new_position.y][new_position.x]
	if target_tile.walkable and target_tile.entity == null:
		map_data[player.position.y][player.position.x].entity = null
		player.position = new_position
		map_data[new_position.y][new_position.x].entity = player
	
	on_action_taken();

func on_action_taken():
	render_map()
