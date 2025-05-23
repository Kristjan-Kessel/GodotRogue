extends Node

class_name LevelGenerator

const min_room_width = 10
const min_room_height = 4
const min_room_offset_x = 1
const min_room_offset_y = 1

# how likely it is for any given room to not existing, 1/room_chance
const room_chance = 20
const max_missing_rooms = 3

static func generate_level(player: Node) -> Array:
    var empty_tile = Tile.new("EMPTY", false, Constants.EMPTY, false, Vector2(-1,-1))
    var map = []
    var room_grid = [[null,null,null],[null,null,null],[null,null,null]]
    var room_list = []

    # To track floor tiles that can support items and enemies (Ex: stairs and player tile cannot.)
    var spawning_tiles = []

    for y in range(Constants.map_height):
        var row = []
        for x in range(Constants.map_width):
            row.append(empty_tile);
        map.append(row)
    
    var loop_count = 0
    var missing_room_count = 0
    
    var valid_rooms = []
    for y in range(3):
        for x in range(3):
            var room = Room.new()
            room.grid_position.x = x
            room.grid_position.y = y
            room_list.append(room)
            valid_rooms.append(room)
    
    for i in range(max_missing_rooms):
        if Globals.level_rng.randi_range(1,room_chance) == 1:
            var room = valid_rooms[Globals.level_rng.randi_range(0,valid_rooms.size()-1)]
            room.skip = true
            valid_rooms.erase(room)
    
    var player_room = valid_rooms[Globals.level_rng.randi_range(0,valid_rooms.size()-1)]
    player_room.is_player_room = true
    valid_rooms.erase(player_room)
    valid_rooms[Globals.level_rng.randi_range(0,valid_rooms.size()-1)].is_exit_room = true
    
    for room in room_list:
        var max_width = Constants.map_width/3
        var max_height = Constants.map_height/3
        var start_x = Constants.map_width/3*room.grid_position.x
        var start_y = Constants.map_height/3*room.grid_position.y
        
        if room.skip:
            room.position.x = Globals.level_rng.randi_range(start_x,start_x+max_width-1)
            room.position.y = Globals.level_rng.randi_range(start_y,start_y+max_height-1)
            missing_room_count += 1
        else:
            var x_offset = Globals.level_rng.randi_range(min_room_offset_x,max_width-min_room_width)
            var y_offset = Globals.level_rng.randi_range(min_room_offset_y,max_height-min_room_height)
        
            start_x += x_offset
            start_y += y_offset
            max_width -= x_offset
            max_height -= y_offset

            room.position.x = start_x
            room.position.y = start_y
            room.size.x = Globals.level_rng.randi_range(min_room_width,max_width)
            room.size.y = Globals.level_rng.randi_range(min_room_height,max_height)
        
        if !room.skip:
            generate_room(map,room,spawning_tiles)
            
            if room.is_exit_room:
                var exit_tile = room.get_random_valid_tile(spawning_tiles, Globals.level_rng)
                exit_tile.type = "STAIRS"
                exit_tile.is_important = true
                exit_tile.ascii = Constants.STAIRS
                spawning_tiles.erase(exit_tile)

            if room.is_player_room:
                var player_tile = room.get_random_valid_tile(spawning_tiles, Globals.level_rng)
                player_tile.entity = player
                player.position = player_tile.position
                spawning_tiles.erase(player_tile)
        
        room_grid[room.grid_position.y][room.grid_position.x] = room
        loop_count+=1
    
    select_and_generate_corridors(map,room_grid,room_list)
        
    generate_loot(spawning_tiles, room_list, player)
    var enemies = generate_enemies(spawning_tiles, room_list, player)
    return [map, enemies, room_list]

static func generate_loot(spawning_tiles: Array, rooms: Array, player: Node):
    var loot_pool
    var valid_tiles = spawning_tiles.duplicate()
    if player.stats.level <= 3:
        loot_pool = Pools.low_tier_loot
    elif player.stats.level <= 6:
        loot_pool = Pools.mid_tier_loot
    elif player.stats.level <= 9:
        loot_pool = Pools.high_tier_loot
    
    var non_skip_rooms = rooms.filter(func(room):
        return !room.skip
    )
    var valid_rooms = non_skip_rooms.duplicate()
    var amount_to_spawn = Globals.level_rng.randi_range(Pools.min_loot,Pools.max_loot)
    for i in range(amount_to_spawn):
        if loot_pool.size() == 0:
            loot_pool = Pools.fallback_pool.duplicate()
        if valid_rooms.size() == 0:
            valid_rooms = non_skip_rooms.duplicate()
        var room = valid_rooms[Globals.level_rng.randi_range(0,valid_rooms.size()-1)]
        var tile = room.get_random_valid_tile(valid_tiles,Globals.level_rng)
        var item = loot_pool[Globals.level_rng.randi_range(0,loot_pool.size()-1)]
        tile.item = item
        valid_tiles.erase(tile)
        valid_rooms.erase(room)
        loot_pool.erase(item)

static func generate_enemies(spawning_tiles: Array, rooms: Array, player: Node):
    var enemy_pool
    var enemies = []
    var valid_tiles = spawning_tiles.duplicate()
    if player.stats.level <= 3:
        enemy_pool = Pools.low_tier_enemies
    elif player.stats.level <= 6:
        enemy_pool = Pools.mid_tier_enemies
    elif player.stats.level <= 9:
        enemy_pool = Pools.high_tier_enemies
    
    var amount_to_spawn = Globals.level_rng.randi_range(Pools.min_enemies,Pools.max_enemies)
    var non_skip_rooms = rooms.filter(func(room):
        return !room.skip
    )
    var valid_rooms = non_skip_rooms.duplicate()
    
    for i in range(amount_to_spawn):
        if valid_rooms.size() == 0:
            valid_rooms = non_skip_rooms.duplicate()
        var room = valid_rooms[Globals.level_rng.randi_range(0,valid_rooms.size()-1)]
        var tile = room.get_random_valid_tile(valid_tiles,Globals.level_rng)
        var enemy_type = enemy_pool[Globals.level_rng.randi_range(0,enemy_pool.size()-1)]
        
        var is_sleeping = Globals.level_rng.randi_range(1,Pools.sleep_chance) == 1
        
        var enemy = EnemyData.new(tile.position,enemy_type,is_sleeping)
        enemies.append(enemy)
        valid_tiles.erase(tile)
        valid_rooms.erase(room)
    
    return enemies

static func select_and_generate_corridors(map: Array, room_grid: Array, room_list: Array):
    var orphan_rooms = room_list.duplicate()
    var current_room = room_list[Globals.level_rng.randi_range(0,room_list.size()-1)]
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

static func get_valid_neighbouring_rooms(room_list: Array, room: Room) -> Array:
    var valid_rooms = []
    for i in room_list:
        var distance = abs((i.grid_position-room.grid_position))
        if distance == Vector2(1,0) || distance == Vector2(0,1):
            valid_rooms.append(i)

    return valid_rooms

static func generate_corridor_between_rooms(map: Array, rooms: Array, start_room: Room, end_room: Room):
    var is_horizontal = start_room.grid_position.x != end_room.grid_position.x
    
    var start = Vector2(0,0)
    var end = Vector2(0,0)
    
    if is_horizontal:
        start.y = Globals.level_rng.randi_range(start_room.position.y+1,start_room.position.y+start_room.size.y-2)
        end.y = Globals.level_rng.randi_range(end_room.position.y+1,end_room.position.y+end_room.size.y-2)
        var dir = end_room.grid_position.x-start_room.grid_position.x
        if dir>0:
            start.x = start_room.position.x+start_room.size.x-1
            end.x = end_room.position.x
        else:
            start.x = start_room.position.x
            end.x = end_room.position.x+end_room.size.x-1
    else:
        start.x = Globals.level_rng.randi_range(start_room.position.x+1,start_room.position.x+start_room.size.x-2)
        end.x = Globals.level_rng.randi_range(end_room.position.x+1,end_room.position.x+end_room.size.x-2)
        var dir = end_room.grid_position.y-start_room.grid_position.y
        if dir>0:
            start.y = start_room.position.y+start_room.size.y-1
            end.y = end_room.position.y
        else:
            start.y = start_room.position.y
            end.y = end_room.position.y+end_room.size.y-1
            
    if start_room.skip:
        start.y = start_room.position.y
        start.x = start_room.position.x
    if end_room.skip:
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

static func carve_corridor_cell(position: Vector2, map: Array):
    
    var current_tile = map[position.y][position.x]
    if current_tile.type == "WALL":
        map[position.y][position.x] = Tile.new("DOOR", true, Constants.DOOR, true, position)
    else:
        map[position.y][position.x] = Tile.new("CORRIDOR", true, Constants.CORRIDOR, false, position)

static func generate_room(map: Array, room: Room, spawning_tiles: Array):
    var tile_grid = []
    for y in range(room.size.y):
        var row = []
        for x in range(room.size.x):
            var position = Vector2(room.position.x+x,room.position.y+y)
            var tile
            if y==0 && x==0:
                tile = Tile.new("WALL", false, Constants.WALL_CORNER_TL, false, position)
            elif y==0 && x==room.size.x-1:
                tile = Tile.new("WALL", false, Constants.WALL_CORNER_TR, false, position)
            elif y==room.size.y-1 && x==0:
                tile = Tile.new("WALL", false, Constants.WALL_CORNER_BL, false, position)
            elif y==room.size.y-1 && x==room.size.x-1:
                tile = Tile.new("WALL", false, Constants.WALL_CORNER_BR, false, position)
            elif y==0 || y==room.size.y-1:
                tile = Tile.new("WALL", false, Constants.WALL_H, false, position)
            elif x==0 || x==room.size.x-1:
                tile = Tile.new("WALL", false, Constants.WALL_V, false, position)
            else:
                tile = Tile.new("FLOOR", true, Constants.FLOOR, false, position)
                spawning_tiles.append(tile)
            map[position.y][position.x] = tile 
            row.append(tile)
        tile_grid.append(row)
    room.tile_grid = tile_grid

static func get_level_from_file(file_name: String, player: Node) -> Array:
    var ascii = get_ascii_from_file(file_name)
    return convert_ascii_to_tiles(ascii, player)

static func get_ascii_from_file(file_name: String) -> Array:
    var path = "res://Preset Levels/" + file_name
    var result = []
    var longest = 0
    if FileAccess.file_exists(path):
        var file = FileAccess.open(path, FileAccess.READ)
        while !file.eof_reached():
            var line = file.get_line()
            var char_array = line.split("", false)
            if line.length() > longest:
                longest = line.length()
            line.rpad(longest, " ")
            result.append(char_array)
        file.close()
    else:
        print("File does not exist: " + path)
    return result

static func get_wall_ascii(ascii_map: Array, x: int, y: int):
    var left = false
    var right = false
    var top = false
    var bottom = false
    
    if y != 0:
        top = ascii_map[y-1][x].type == "WALL" || ascii_map[y-1][x].type == "DOOR"
    if x != 0:
        right = ascii_map[y][x-1].type == "WALL" || ascii_map[y][x-1].type == "DOOR"

    left = ascii_map[y][x+1].type == "WALL" || ascii_map[y][x+1].type == "DOOR"
    bottom = ascii_map[y+1][x].type == "WALL" || ascii_map[y+1][x].type == "DOOR"
    
    if top && bottom:
        return Constants.WALL_V
    elif left && right:
        return Constants.WALL_H
    elif top && right:
        return Constants.WALL_CORNER_BR
    elif top && left:
        return Constants.WALL_CORNER_BL
    elif bottom && right:
        return Constants.WALL_CORNER_TR
    elif bottom && left:
        return Constants.WALL_CORNER_TL
    else:
        return "F"
    
static func convert_ascii_to_tiles(ascii_map: Array, player: Node) -> Array:
    var tile_map = []
    var walls = []
    var empty_tile = Tile.new("EMPTY", false, Constants.EMPTY, false, Vector2(-1,-1))
    for y in range(Constants.map_height):
        var row = []
        for x in range(Constants.map_width):
            row.append(empty_tile);
        tile_map.append(row)
    
    var ascii_width = ascii_map[0].size()
    var ascii_height = ascii_map.size()
    var offset_x = int((Constants.map_width - ascii_width) / 2)
    var offset_y = int((Constants.map_height - ascii_height) / 2)
    
    var enemies = []
    for y in range(ascii_map.size()):
        for x in range(ascii_map[y].size()):
            var tile = null
            var position = Vector2(x+offset_x,y+offset_y)
            match ascii_map[y][x]:
                Constants.TXT_WALL:
                    tile = Tile.new("WALL", false, "", false, position)
                    walls.append(tile)
                Constants.TXT_FLOOR:
                    tile = Tile.new("FLOOR", true, Constants.FLOOR,false, position)
                Constants.TXT_DOOR:
                    tile = Tile.new("DOOR", true, Constants.DOOR,true, position)
                Constants.TXT_CORRIDOR:
                    tile = Tile.new("CORRIDOR",true,Constants.CORRIDOR,false, position)
                Constants.TXT_PLAYER:
                    tile = Tile.new("FLOOR",true,Constants.FLOOR,false, position)
                    player.position = position;
                    tile.entity = player
                Constants.TXT_GOLD:
                    tile = Tile.new("FLOOR",true,Constants.FLOOR, false, position)
                    tile.item = Gold.new()
                Constants.TXT_STAIRS:
                    tile = Tile.new("STAIRS",true,Constants.STAIRS, false, position)
                "g":
                    tile = Tile.new("FLOOR",true,Constants.FLOOR,false, position)
                    var enemy = EnemyData.new(position,"goblin", false)
                    enemies.append(enemy)
                "i":
                    tile = Tile.new("FLOOR",true,Constants.FLOOR,false, position)
                    var enemy = EnemyData.new(position,"icemonster", false)
                    enemies.append(enemy)
                "d":
                    tile = Tile.new("FLOOR",true,Constants.FLOOR,false, position)
                    var enemy = EnemyData.new(position,"drake", false)
                    enemies.append(enemy)
                Constants.TXT_ARTIFACT:
                    tile = Tile.new("FLOOR", true, Constants.FLOOR, false, position)
                    tile.item = Artifact.new()
                _:
                    tile = Tile.new("EMPTY", false,Constants.EMPTY, false, position)
            tile_map[y+offset_y][x+offset_x] = tile
    
    for wall in walls:
        wall.ascii = get_wall_ascii(tile_map,wall.position.x,wall.position.y)
    
    return [tile_map,enemies]
