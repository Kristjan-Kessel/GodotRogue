extends Node

class_name LevelGenerator

static func generate_basic_room(width: int, height: int) -> Array:
	var map = []
	for y in range(height):
		var row = []
		for x in range(width):
			if y == 0 or y == height - 1 or x == 0 or x == width - 1:
				row.append(Constants.WALL)
			else:
				row.append(Constants.FLOOR)
		map.append(row)
	return map

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
