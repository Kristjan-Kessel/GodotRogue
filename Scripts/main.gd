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
	ui.update_stats(player)
	new_level()

func get_tile(position: Vector2) -> Tile:
	return map_data[position.y][position.x]

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		new_level()

func new_level():
	var ascii_map = LevelGenerator.generate_level()
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
	move_player(new_position)

func move_player(new_position: Vector2) -> bool:
	new_position.x = clamp(new_position.x, 0, Globals.map_width - 1)
	new_position.y = clamp(new_position.y, 0, Globals.map_height - 1)
	var moved = false
	
	var target_tile = map_data[new_position.y][new_position.x]
	if target_tile.is_walkable and target_tile.entity == null:
		map_data[player.position.y][player.position.x].entity = null
		player.position = new_position
		map_data[new_position.y][new_position.x].entity = player
		moved = true
	
	ui.set_log_message("You moved to " + str(player.position))
	on_action_taken();
	return moved
	
func on_action_taken():
	render_map()
	ui.update_stats(player)

func _on_player_log_message(new_message: Variant) -> void:
	ui.set_log_message(new_message)

func _on_player_command_find(direction: Vector2) -> void:
	var bypass_important = true
	while true:
		var new_position = player.position + direction
		var next_tile = get_tile(new_position)
		
		var left_direction = direction.rotated(deg_to_rad(-90))
		var right_direction = direction.rotated(deg_to_rad(90))
		
		var left_tile = get_tile(player.position + left_direction)
		var right_tile = get_tile(player.position + right_direction)
		
		if !bypass_important:
			if left_tile.is_important:
				break
			if right_tile.is_important:
				break
			if next_tile.is_important:
				break
		bypass_important = false
		var moved = move_player(new_position)
		if !moved:
			if get_tile(player.position).type == "CORRIDOR":
				if left_tile.is_walkable:
					direction = left_direction
					bypass_important = true
				elif right_tile.is_walkable:
					direction = right_direction
					bypass_important = true
				else:
					break
			else:
				break
		
