extends Node

class_name LevelGenerator

const min_room_width = 16
const min_room_height = 4

static func generate_level() -> Array:
	var map = []
	
	#make empty array with the max width and height
	for y in range(Globals.map_height):
		var row = []
		for x in range(Globals.map_width):
			row.append(Constants.EMPTY);
		map.append(row)
	
	var player_spawned = false
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
			
			generate_basic_room(map,start_x,start_y,width,height)
			
			if(!player_spawned):
				if(Globals.level_rng.randf()>0.66 || (y==2 && x==2)):
					map[start_y+height/2][start_x+width/2] = Constants.PLAYER
					player_spawned = true;
			
	return map

static func generate_basic_room(map: Array, start_x: int,start_y: int,width: int, height: int):
	for y in range(height):
		for x in range(width):
			if(x == 0 || x==width-1):
				map[start_y+y][start_x+x] = Constants.WALL
			elif(y == 0 || y==height-1):
				map[start_y+y][start_x+x] = Constants.CEILING
			else:
				map[start_y+y][start_x+x] = Constants.FLOOR


static func convert_ascii_to_tiles(ascii_map: Array, player: Node) -> Array:
	var tile_map = []
	for y in range(ascii_map.size()):
		var row = []
		for x in range(ascii_map[y].size()):
			var char = ascii_map[y][x]
			var tile = null
			match char:
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
