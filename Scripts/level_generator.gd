extends Node

class_name LevelGenerator

const min_room_width = 24
const min_room_height = 4

static func generate_level() -> Array:
	var map = []
	var rooms = [[null,null,null],[null,null,null],[null,null,null]]
	#make empty array with the max width and height
	for y in range(Globals.map_height):
		var row = []
		for x in range(Globals.map_width):
			row.append(Constants.EMPTY);
		map.append(row)
	
	var loop_count = 0
	var player_loop = Globals.level_rng.randi_range(0,8)
	for y in range(3):
		for x in range(3):
			# x and y are room starting points
			var max_width = Globals.map_width/3
			var max_height = Globals.map_height/3
			var start_x = Globals.map_width/3*x
			var start_y = Globals.map_height/3*y
			
			var x_offset = Globals.level_rng.randi_range(1,4)
			var y_offset = Globals.level_rng.randi_range(1,3)
			
			start_x += x_offset
			start_y += y_offset
			max_width -= x_offset
			max_height -= y_offset
			
			var width = Globals.level_rng.randi_range(min_room_width,max_width)
			var height = Globals.level_rng.randi_range(min_room_height,max_height)
			
			var room = Rect2(start_x,start_y,width,height)
			generate_basic_room(map,room)
			if(loop_count==player_loop):
				map[start_y+height/2][start_x+width/2] = Constants.PLAYER
			rooms[y][x] = room
			loop_count+=1
	
	generate_corridor_between_rooms(map, rooms, Vector2(0,0), Vector2(0,1))
	generate_corridor_between_rooms(map, rooms, Vector2(0,1), Vector2(0,2))
	
	generate_corridor_between_rooms(map, rooms, Vector2(0,0), Vector2(1,0))
	generate_corridor_between_rooms(map, rooms, Vector2(1,0), Vector2(2,0))
	
	generate_corridor_between_rooms(map, rooms, Vector2(0,1), Vector2(1,1))
	generate_corridor_between_rooms(map, rooms, Vector2(1,1), Vector2(2,1))
	generate_corridor_between_rooms(map, rooms, Vector2(0,2), Vector2(1,2))
	generate_corridor_between_rooms(map, rooms, Vector2(2,2), Vector2(1,2))
	return map

static func generate_corridor_between_rooms(map: Array, rooms: Array, start_vector: Vector2, end_vector: Vector2):
	var start_room: Rect2 = rooms[start_vector.y][start_vector.x]
	var end_room: Rect2 = rooms[end_vector.y][end_vector.x]
	
	var horizontal = start_vector.x != end_vector.x
	
	var start = Vector2(0,0)
	var end = Vector2(0,0)
	
	if(horizontal):
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
	print(start)
	print(end)
	generate_corridor(map,start,end)

static func generate_corridor(map: Array, start: Vector2, end: Vector2):
	var i = start
	var direction = (end-i).sign()
	while true:
		if map[i.y][i.x] == Constants.WALL || map[i.y][i.x] == Constants.CEILING:
			map[i.y][i.x] = Constants.DOOR
		else:
			map[i.y][i.x] = Constants.CORRIDOR
			
		if i.distance_to(end)==0:
			break
		
		if(i.x != end.x):
			i.x+=direction.x
		else:
			i.y+=direction.y

static func generate_basic_room(map: Array, room: Rect2):
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
	for y in range(ascii_map.size()):
		var row = []
		for x in range(ascii_map[y].size()):
			var tile = null
			match ascii_map[y][x]:
				Constants.WALL:
					tile = Tile.new("wall", false, Constants.WALL)
				Constants.CEILING:
					tile = Tile.new("wall", false, Constants.CEILING)
				Constants.FLOOR:
					tile = Tile.new("floor", true, Constants.FLOOR)
				Constants.DOOR:
					tile = Tile.new("door", true, Constants.DOOR)
				Constants.CORRIDOR:
					tile = Tile.new("corridor",true,Constants.CORRIDOR)
				Constants.PLAYER:
					tile = Tile.new("floor",true,Constants.FLOOR)
					player.position = Vector2(x,y);
					tile.entity = player			
				_:
					tile = Tile.new("empty", false,Constants.EMPTY)
			row.append(tile)
		tile_map.append(row)
	return tile_map
