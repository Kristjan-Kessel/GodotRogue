extends Node

class_name LevelGenerator

const min_room_width = 10
const min_room_height = 4
const min_room_offset_x = 1
const min_room_offset_y = 1

#how likely it is for any given room to not existing, 1/room_chance
const room_chance = 10
const max_missing_rooms = 1


static func generate_level() -> Array:
	var map = []
	var room_grid = [[null,null,null],[null,null,null],[null,null,null]]
	var room_vector_list = []

	for y in range(Globals.map_height):
		var row = []
		for x in range(Globals.map_width):
			row.append(Constants.EMPTY);
		map.append(row)
	
	var loop_count = 0
	var player_room = Globals.level_rng.randi_range(0,8)
	var exit_room = Globals.level_rng.randi_range(0,8)
	var missing_room_count = 0
	for y in range(3):
		for x in range(3):
			var is_spawn_room = loop_count == player_room
			var is_exit_room = loop_count == exit_room
			var skip_room = Globals.level_rng.randi_range(1,room_chance) == 1 && !is_spawn_room && !is_exit_room && missing_room_count < max_missing_rooms
			
			var max_width = Globals.map_width/3
			var max_height = Globals.map_height/3
			var start_x = Globals.map_width/3*x
			var start_y = Globals.map_height/3*y
			
			var room
			
			if skip_room:
				room = Rect2(Globals.level_rng.randi_range(start_x,start_x+max_width-1),Globals.level_rng.randi_range(start_y,start_y+max_height-1),1,1)
				missing_room_count += 1
			else:
				var x_offset = Globals.level_rng.randi_range(min_room_offset_x,max_width-min_room_width)
				var y_offset = Globals.level_rng.randi_range(min_room_offset_y,max_height-min_room_height)
			
				start_x += x_offset
				start_y += y_offset
				max_width -= x_offset
				max_height -= y_offset
				
				var width = Globals.level_rng.randi_range(min_room_width,max_width)
				var height = Globals.level_rng.randi_range(min_room_height,max_height)
				
				room = Rect2(start_x,start_y,width,height)
			
			if !skip_room:
				generate_room(map,room)
			
			if is_spawn_room:
				map[start_y+room.size.y/2][start_x+room.size.x/2] = Constants.PLAYER
			room_grid[y][x] = room
			room_vector_list.append(Vector2(x,y))
			loop_count+=1
	
	select_and_generate_corridors(map,room_grid,room_vector_list)
	
	return map
	
static func select_and_generate_corridors(map: Array, room_grid: Array, room_vector_list: Array):
	var orphan_rooms = Array(room_vector_list)
	var current_room = room_vector_list[Globals.level_rng.randi_range(0,room_vector_list.size()-1)]
	var connected_rooms = []
	var initial_path_length = 1
	orphan_rooms.erase(current_room)
	connected_rooms.append(current_room)
	
	while orphan_rooms.size()>0:
		for orphan in orphan_rooms:
			var valid_rooms = get_valid_neighbouring_rooms(connected_rooms,orphan)
			if valid_rooms.size() > 0:
				var next_room = valid_rooms[Globals.level_rng.randi_range(0,valid_rooms.size()-1)]
				generate_corridor_between_rooms(map,room_grid,orphan,next_room)
				orphan_rooms.erase(orphan)
				connected_rooms.append(orphan)

static func get_valid_neighbouring_rooms(room_vector_list: Array, room: Vector2) -> Array:
	var valid_rooms = []
	for i in room_vector_list:
		var distance = abs((i-room))
		if distance == Vector2(1,0) || distance == Vector2(0,1):
			valid_rooms.append(i)

	return valid_rooms


static func generate_corridor_between_rooms(map: Array, rooms: Array, start_vector: Vector2, end_vector: Vector2):
	var start_room: Rect2 = rooms[start_vector.y][start_vector.x]
	var end_room: Rect2 = rooms[end_vector.y][end_vector.x]
	
	var is_horizontal = start_vector.x != end_vector.x
	
	var start = Vector2(0,0)
	var end = Vector2(0,0)
	
	if is_horizontal:
		start.y = Globals.level_rng.randi_range(start_room.position.y+1,start_room.position.y+start_room.size.y-2)
		end.y = Globals.level_rng.randi_range(end_room.position.y+1,end_room.position.y+end_room.size.y-2)
		var dir = end_vector.x-start_vector.x
		if dir>0:
			start.x = start_room.position.x+start_room.size.x-1
			end.x = end_room.position.x
		else:
			start.x = start_room.position.x
			end.x = end_room.position.x+end_room.size.x-1
	else:
		start.x = Globals.level_rng.randi_range(start_room.position.x+1,start_room.position.x+start_room.size.x-2)
		end.x = Globals.level_rng.randi_range(end_room.position.x+1,end_room.position.x+end_room.size.x-2)
		var dir = end_vector.y-start_vector.y
		if dir>0:
			start.y = start_room.position.y+start_room.size.y-1
			end.y = end_room.position.y
		else:
			start.y = start_room.position.y
			end.y = end_room.position.y+end_room.size.y-1
			
	if start_room.size.y==1:
		start.y = start_room.position.y
		start.x = start_room.position.x
	if end_room.size.y==1:
		end.y = end_room.position.y
		end.x = end_room.position.x
	
	#draw_corridor_randomly(start,end,map,is_horizontal)
	draw_corridor_shaped(start,end,map,is_horizontal)

static func draw_corridor_shaped(start: Vector2, end: Vector2, map: Array, is_horizontal:bool):
	var cursor = start
	var direction = (end - cursor).sign()
	var total_distance = (end - start).abs()
	var first_turn = 0
	if is_horizontal:
		if total_distance.x>4:
			first_turn = Globals.level_rng.randi_range(2,total_distance.x-2)
		else:
			first_turn = Globals.level_rng.randi_range(1,total_distance.x-1)
	else:
		if total_distance.y>4:
			first_turn = Globals.level_rng.randi_range(2,total_distance.y-2)
		else:
			first_turn = Globals.level_rng.randi_range(1,total_distance.y-1)
	
	var counter = 0
	while true:
		carve_corridor_cell(cursor,map)
		
		if counter==first_turn || cursor==end:
			break
		
		if is_horizontal:
			cursor.x += direction.x
		else:
			cursor.y += direction.y
			
		counter+=1
	
	while true:
		carve_corridor_cell(cursor,map)
		
		if cursor==end || (is_horizontal && cursor.y==end.y) || (!is_horizontal && cursor.x==end.x):
			break
		
		if !is_horizontal:
			cursor.x += direction.x
		else:
			cursor.y += direction.y
		
	while true:
		carve_corridor_cell(cursor,map)
		
		if cursor==end:
			break
		
		if is_horizontal:
			cursor.x += direction.x
		else:
			cursor.y += direction.y
	
static func draw_corridor_randomly(start: Vector2, end: Vector2, map: Array, is_horizontal:bool):
	var cursor = start
	var direction = (end - cursor).sign()
	var total_distance = (end - start).abs()

	while true:
		carve_corridor_cell(cursor,map)
		
		if cursor == end:
			break
		
		var current_distance = (end - cursor).abs()

		# Make sure a corridor wont be drawn through multiple walls.
		# If possible (based on distance between rooms), make it so the corridor wont touch the wall of the start and end room sides
		if is_horizontal:
			var move_horizontal = (cursor.x == start.x) or (total_distance.x > 3 and cursor.x == start.x + direction.x)
			var move_vertical = ((total_distance.x > 3 and current_distance.x == 2) or (current_distance.x == 1)) and (end.y != cursor.y)
			
			if move_horizontal:
				cursor.x += direction.x
				continue
			elif move_vertical:
				cursor.y += direction.y
				continue
		else:
			var move_vertical = (cursor.y == start.y) or (total_distance.y > 3 and cursor.y == start.y + direction.y)
			var move_horizontal = ((total_distance.y > 3 and current_distance.y == 2) or (current_distance.y == 1)) and (end.x != cursor.x)
			
			if move_vertical:
				cursor.y += direction.y
				continue
			elif move_horizontal:
				cursor.x += direction.x
				continue
		
		# Ensures that the corridor wont overshoot the end destination
		if cursor.x == end.x:
			cursor.y += direction.y
		elif cursor.y == end.y:
			cursor.x += direction.x
		else:
			if Globals.level_rng.randi_range(0, 1) == 1:
				cursor.x += direction.x
			else:
				cursor.y += direction.y

static func carve_corridor_cell(cursor: Vector2, map: Array):
	if map[cursor.y][cursor.x] == Constants.WALL || map[cursor.y][cursor.x] == Constants.CEILING:
		map[cursor.y][cursor.x] = Constants.DOOR
	else:
		map[cursor.y][cursor.x] = Constants.CORRIDOR

static func generate_room(map: Array, room: Rect2):
	for y in range(room.size.y):
		for x in range(room.size.x):
			if(y == 0 || y==room.size.y-1):
				map[room.position.y+y][room.position.x+x] = Constants.CEILING
			elif(x == 0 || x==room.size.x-1):
				map[room.position.y+y][room.position.x+x] = Constants.WALL
			else:
				map[room.position.y+y][room.position.x+x] = Constants.FLOOR

static func convert_ascii_to_tiles(ascii_map: Array, player: Node) -> Array:
	var tile_map = []
	var enemies = []
	var id = 0
	for y in range(ascii_map.size()):
		var row = []
		for x in range(ascii_map[y].size()):
			var tile = null
			match ascii_map[y][x]:
				Constants.WALL:
					tile = Tile.new("WALL", false, Constants.WALL,false, id)
				Constants.CEILING:
					tile = Tile.new("WALL", false, Constants.CEILING,false, id)
				Constants.FLOOR:
					tile = Tile.new("FLOOR", true, Constants.FLOOR,false, id)
				Constants.DOOR:
					tile = Tile.new("DOOR", true, Constants.DOOR,true, id)
				Constants.CORRIDOR:
					tile = Tile.new("CORRIDOR",true,Constants.CORRIDOR,false, id)
				Constants.PLAYER:
					tile = Tile.new("FLOOR",true,Constants.FLOOR,false, id)
					player.position = Vector2(x,y);
					tile.entity = player
				Constants.GOLD:
					tile = Tile.new("FLOOR",true,Constants.FLOOR,false, id)
					tile.item = Gold.new()
				"&":
					tile = Tile.new("FLOOR",true,Constants.FLOOR,false, id)
					var enemy = EnemyData.new(Vector2(x,y),"res://Scripts/Enemies/goblin.tscn")
					enemies.append(enemy)
				_:
					tile = Tile.new("EMPTY", false,Constants.EMPTY, false, id)
			row.append(tile)
			id += 1
		tile_map.append(row)
	return [tile_map,enemies]

static func get_ascii_from_file(file_name: String) -> Array:
	var path = "res://Test Levels/" + file_name
	var result = []
	
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		while !file.eof_reached():
			var line = file.get_line()
			var char_array = line.split("", false)
			result.append(char_array)
		file.close()
	else:
		print("File does not exist: " + path)
	
	return result
