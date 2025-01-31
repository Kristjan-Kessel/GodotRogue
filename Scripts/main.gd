extends Node2D

var map_data : Array = []
@onready var level = $UI/MapLabel
@onready var player = $Player
@onready var ui = $UI

var test_map = [
	["","|", "-", "-", "|", " ", " ", " ", "|", "-", "-", "|"],
	["","|", "@", ".", "+", "#", "#", "#", "+", ".", ".", "|"],
	["","|", ".", ".", "|", " ", " ", " ", "|", ".", ".", "|"],
	["","|", "-", "-", "|", " ", " ", " ", "|", "-", "-", "|"],
]

func _ready():
	Globals.initialize_randomness()
	print("Using seed: ", Globals.rng_seed)
	var ascii_map = test_map #LevelGenerator.generate_basic_room(Globals.map_width, Globals.map_height)
	map_data = LevelGenerator.convert_ascii_to_tiles(ascii_map, player)
	
	render_map()

func render_map():
	var map_str = ""
	for y in range(map_data.size()):
		for x in range(map_data[y].size()):
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
	
	#ui.update_stats(player.hp, player.gold, player.level)  # Update stats
	ui.set_log_message("You moved to " + str(new_position))  # Log movement
	on_action_taken();

func on_action_taken():
	render_map()
