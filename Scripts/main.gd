extends Node2D

const debug_sight = false

var map_data : Array = []
@onready var level = $UI/Background/MapLabel
@onready var player = $Player
@onready var ui = $UI
@onready var enemies = $Enemies

var log_message = ""

var astar = AStar2D.new()
var astar_bypass = AStar2D.new()

@export var turn = 0

func _ready():
    Globals.initialize_randomness()
    print("Using seed: ", Globals.rng_seed)
    ui.update_stats(player, turn)
    new_level()
    #test_level("final.txt")
    #test_level("test.txt")

func get_tile(position: Vector2) -> Tile:
    if position.y >= 0 and position.y < map_data.size():
        var row = map_data[position.y]
        if position.x >= 0 and position.x < row.size():
            return map_data[position.y][position.x]
    return null

func get_tile_neighbours(tile: Tile) -> Array:
    var tiles = []
    for offset in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
        var nx = tile.position.x + offset.x
        var ny = tile.position.y + offset.y
        var ntile = get_tile(Vector2(nx,ny))
        if ntile != null:
            tiles.append(ntile)
    return tiles

func update_astar():
    for y in range(map_data.size()):
        for x in range(map_data[y].size()):
            var tile = map_data[y][x]
            if tile.is_walkable and (tile.entity == null or tile.entity == player):
                connect_tile(tile)

func connect_tile(tile):
    astar.add_point(tile.id, tile.position)
    astar_bypass.add_point(tile.id, tile.position)
    for ntile in get_tile_neighbours(tile):
        if ntile != null && ntile.is_walkable && astar.has_point(ntile.id):
            astar.connect_points(tile.id, ntile.id)
            astar_bypass.connect_points(tile.id,ntile.id)

var enemy_cache = {}
func spawn_enemies_from_list(enemy_list):
    for enemy_data in enemy_list:
        var enemy_scene = enemy_cache.get(enemy_data.path)
        if enemy_scene == null:
            enemy_scene = load(enemy_data.path)
            enemy_cache[enemy_data.path] = enemy_scene

        var enemy = enemy_scene.instantiate()
        enemy.position = enemy_data.position
        enemies.add_child(enemy)
        if enemy_data.is_sleeping:
            enemy.state = Enemy.State.SLEEPING

        var tile = get_tile(enemy_data.position)
        tile.entity = enemy
        enemy.enemy_move.connect(move_enemy)

func test_level(file: String):
    var level_data = LevelGenerator.get_level_from_file(file,player)
    map_data = level_data[0]
    spawn_enemies_from_list(level_data[1])
    update_astar()
    reveal_room(get_tile(player.position))
    render_map()

func new_level():
    var level_data
    if player.stats.level > 9:
        level_data = LevelGenerator.get_level_from_file("final.txt",player)
    else:
        level_data = LevelGenerator.generate_level(player)
    map_data = level_data[0]
    spawn_enemies_from_list(level_data[1])
    update_astar()
    reveal_room(get_tile(player.position))
    render_map()

func render_map():
    var ptile = get_tile(player.position)
    
    # Checks for line of sight with enemies
    for enemy in enemies.get_children():
        var max_distance = 99
        var is_visible = true
        var etile = get_tile(enemy.position)
        connect_tile(etile)
        var path = astar.get_point_path(ptile.id,etile.id)
        var distance = 0
        for i in range(1, path.size() - 1):
            var tile = get_tile(path[i])
            distance += 1
            if tile.type == "CORRIDOR":
                max_distance = 1
            if distance >= max_distance:
                is_visible = false
                break
            if tile.type == "DOOR":
                is_visible = false
                break
            
        enemy.is_visible = is_visible || debug_sight
        astar.remove_point(etile.id)
        
    var map_str = log_message+"\n"
    for y in range(map_data.size()):
        for x in range(map_data[y].size()):
            var tile = map_data[y][x]
            if tile.discovered || debug_sight:
                if tile.entity != null && (tile.entity == player || tile.entity.is_visible):
                    map_str += tile.entity.ascii
                elif tile.item != null:
                    map_str += tile.item.ascii
                else:
                    map_str += tile.ascii
            else:
                map_str += " "
        map_str += "\n"
    level.text = map_str

func reveal_room(start_tile: Tile):
    var queue = [start_tile]
    var visited = {}

    while queue.size() > 0:
        var current_tile = queue.pop_front()
        var pos = current_tile.position

        if visited.has(pos):
            continue
        visited[pos] = true

        current_tile.discovered = true

        for ntile in get_tile_neighbours(current_tile):
            if ntile.type in ["WALL", "FLOOR", "DOOR", "STAIRS"]:
                queue.append(ntile)

func render_inventory(text: String, items: Array):
    var map_str = ""
    for i in range(0,player.inventory.size()):
        var item = player.inventory[i]
        if items.has(item):
            map_str += Constants.INVENTORY_CHARS[i]+") "
            map_str += item.label
            if item == player.armor_item:
                map_str += " (Currently being worn)"
            elif item == player.weapon_item:
                map_str += " (Currently being wielded)"
            map_str += "\n"
    
    ui.set_stats_message(text)
    level.text = map_str

func move_enemy(new_position: Vector2, enemy: Enemy):
    new_position.x = clamp(new_position.x, 0, Globals.map_width - 1)
    new_position.y = clamp(new_position.y, 0, Globals.map_height - 1)
    var target_tile = get_tile(new_position)
    if target_tile.is_walkable:
        if target_tile.entity == null:
            get_tile(enemy.position).entity = null
            enemy.position = new_position
            target_tile.entity = enemy
        elif target_tile.entity == player:
            log_message = enemy.attack_player(player)
            render_map()
    var point_id = get_tile(enemy.position).id
    if astar.has_point(point_id):
        astar.remove_point(point_id)

func move_player(new_position: Vector2) -> bool:
    log_message = ""
    
    new_position.x = clamp(new_position.x, 0, Globals.map_width - 1)
    new_position.y = clamp(new_position.y, 0, Globals.map_height - 1)
    var moved = false
    
    var target_tile = get_tile(new_position)
    if target_tile != null && target_tile.is_walkable:
        if target_tile.entity == null:
            get_tile(player.position).entity = null
            player.position = new_position
            target_tile.entity = player
            moved = true
            
            if target_tile.type == "DOOR" || target_tile.type == "CORRIDOR":
                for ntile in get_tile_neighbours(target_tile):
                    if !ntile.discovered:
                        if ntile.type == "FLOOR":
                            reveal_room(ntile)
                        if ntile.type == "CORRIDOR" || ntile.type == "DOOR":
                            ntile.discovered = true
            
            if target_tile.item != null:
                var item = target_tile.item
                log_message = item.on_pickup(player, target_tile)
                target_tile.item = null
        else:
            var entity = target_tile.entity
            player.attack_enemy(entity)
            return moved
    on_action_taken();
    return moved

func on_action_taken():
    player.stats.turns_until_regen -= 1
    var player_tile = get_tile(player.position)
    connect_tile(player_tile)
    
    for enemy in enemies.get_children():
        var tile = get_tile(enemy.position)
        if enemy.health <= 0:
            log_message = "You defeated the %s." % enemy.label
            tile.entity = null
            player.stats.exp += Globals.rng.randi_range(1,2)
            enemy.queue_free()
            connect_tile(tile)
        else:
            connect_tile(tile)
            # Check for line of sight with player
            var bypass_path = astar_bypass.get_point_path(tile.id, player_tile.id)
            var is_visible = true
            for point in bypass_path:
                var ptile = get_tile(point)
                if ptile.type == "DOOR" && ptile.entity != player:
                    is_visible = false
                    break
            enemy.can_see_player = is_visible
            var path = astar.get_point_path(tile.id, player_tile.id)
            enemy.on_turn(path,bypass_path)
    
    render_map()
    turn += 1
    ui.update_stats(player, turn)

func _on_player_move(new_position: Vector2) -> void:
    move_player(new_position)

func _on_player_log_message(new_message: Variant) -> void:
    log_message = new_message
    render_map()

func _on_player_command_find(direction: Vector2) -> void:
    var bypass_important = true
    var last_tile = get_tile(player.position)
    while true:
        var new_position = player.position + direction
        var next_tile = get_tile(new_position)
        
        var left_direction = direction.rotated(deg_to_rad(-90))
        var right_direction = direction.rotated(deg_to_rad(90))
        
        var left_tile = get_tile(player.position + left_direction)
        var right_tile = get_tile(player.position + right_direction)
        
        # Makes it so the player always starts moving
        if !bypass_important:
            if left_tile != null && left_tile.is_interesting():
                break
            if right_tile != null && right_tile.is_interesting():
                break
            if next_tile != null && next_tile.is_interesting():
                break
        bypass_important = false
        
        last_tile = get_tile(player.position)
        var moved = move_player(new_position)
        
        # Check if player is at a corridor intersection
        if next_tile.type == "CORRIDOR":
            var walkable_directions = 0
            for ntile in get_tile_neighbours(next_tile):
                if ntile.type == "CORRIDOR" && ntile != last_tile:
                    walkable_directions += 1
            if walkable_directions > 1:
                break
        
        # Makes the player continue through corridor turns
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

func _on_player_open_inventory(text: String, items: Array) -> void:
    render_inventory(text,items)

func _on_player_render_map() -> void:
    render_map()
    ui.update_stats(player,turn)

func _on_player_drop_item(item: Variant) -> void:
    var tile = get_tile(player.position)
    if tile.item != null:
        log_message = "Tile already has item."
        return
    
    tile.item = item
    log_message = "You dropped "+item.label
    player.inventory.erase(item)
    
    render_map()

func _on_stats_player_death() -> void:
    pass

func _on_player_open_help_menu() -> void:
    var file = FileAccess.open("res://Assets/help.txt", FileAccess.READ)
    if file:
        var text = file.get_as_text()
        ui.set_stats_message("- Press space to continue -")
        level.text = text

func _on_player_use_stairs() -> void:
    var tile = get_tile(player.position)
    if tile.type == "STAIRS":
        player.stats.level += 1
        new_level()
        ui.update_stats(player,turn)
        render_map()
