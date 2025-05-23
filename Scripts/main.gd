extends Node2D

@export var debug_sight = false

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
    astar.clear()
    astar_bypass.clear()
    for y in range(map_data.size()):
        for x in range(map_data[y].size()):
            var tile = map_data[y][x]
            if tile.is_walkable:
                if tile.entity == null or tile.entity == player:
                    connect_tile(tile,astar)
                connect_tile(tile,astar_bypass)

func connect_tile(tile, astar_i):
    astar_i.add_point(tile.id, tile.position)
    for ntile in get_tile_neighbours(tile):
        if ntile != null && ntile.is_walkable && astar_i.has_point(ntile.id):
            astar_i.connect_points(tile.id, ntile.id)

var enemy_cache = {}
var enemy_node_scene = load("res://Scripts/Enemies/Base/enemy_node.tscn")
func spawn_enemies_from_list(enemy_list):
    for enemy_data in enemy_list:
        var enemy_script = enemy_cache.get(enemy_data.path)
        if enemy_script == null:
            enemy_script = load(enemy_data.path)
            enemy_cache[enemy_data.path] = enemy_script

        var enemy = enemy_node_scene.instantiate()
        enemy.set_script(enemy_script)
        enemy.position = enemy_data.position
        enemies.add_child(enemy)
        if enemy_data.is_sleeping:
            enemy.state = Enemy.State.SLEEPING

        var tile = get_tile(enemy_data.position)
        tile.entity = enemy
        astar.remove_point(tile.id)
        enemy.enemy_move.connect(move_enemy)

func test_level(file: String):
    var level_data = LevelGenerator.get_level_from_file(file,player)
    map_data = level_data[0]
    update_astar()
    spawn_enemies_from_list(level_data[1])
    reveal_room(get_tile(player.position))
    render_map()

func new_level():
    var level_data
    if player.stats.level > 9:
        level_data = LevelGenerator.get_level_from_file("final.txt",player)
    else:
        level_data = LevelGenerator.generate_level(player)
    map_data = level_data[0]
    
    for child in enemies.get_children():
        child.free()
    
    update_astar()
    spawn_enemies_from_list(level_data[1])
    reveal_room(get_tile(player.position))
    render_map()

func render_map():
    var ptile = get_tile(player.position)
    
    # Checks for line of sight with enemies
    for enemy in enemies.get_children():
        var max_distance = 99
        var is_visible = true
        var etile = get_tile(enemy.position)
        var path = astar_bypass.get_point_path(ptile.id,etile.id)
        for i in range(1, path.size() - 1):
            var tile = get_tile(path[i])
            if tile.type == "CORRIDOR":
                max_distance = 1
            if i >= max_distance:
                is_visible = false
                break
            if tile.type == "DOOR":
                is_visible = false
                break
            
        enemy.is_visible = is_visible || debug_sight
        
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
    new_position.x = clamp(new_position.x, 0, Constants.map_width - 1)
    new_position.y = clamp(new_position.y, 0, Constants.map_height - 1)
    var target_tile = get_tile(new_position)
    if target_tile.is_walkable:
        if target_tile.entity == null:
            get_tile(enemy.position).entity = null
            enemy.position = new_position
            target_tile.entity = enemy
        elif target_tile.entity == player:
            log_message = enemy.attack_player(player)
            render_map()

func move_player(new_position: Vector2) -> bool:
    
    if player.stunned:
        log_message = "You are stunned. [continue]"
        render_map()
        return false
    
    log_message = ""
    
    new_position.x = clamp(new_position.x, 0, Constants.map_width - 1)
    new_position.y = clamp(new_position.y, 0, Constants.map_height - 1)
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
                        if ntile.type == "FLOOR" || ntile.type == "STAIRS":
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
    connect_tile(player_tile,astar)
    
    for enemy in enemies.get_children():
        var tile = get_tile(enemy.position)
        if enemy.health <= 0:
            log_message = "You defeated the %s." % enemy.label
            tile.entity = null
            player.stats.exp += Globals.rng.randi_range(enemy.min_exp,enemy.max_exp)
            enemy.queue_free()
            connect_tile(tile,astar)
        else:
            connect_tile(tile,astar)
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
            astar.remove_point(get_tile(enemy.position).id)
    
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
        
        # Because sometimes the find move will start next to an interesting tile, this will skip the first tile.
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

const LOSE_SCENE_PATH := "res://Scenes/LoseScreen.tscn"
func _on_player_death() -> void:
    get_tree().change_scene_to_file(LOSE_SCENE_PATH)

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

const WIN_SCENE_PATH := "res://Scenes/WinScreen.tscn"
func _on_player_win() -> void:
    Globals.final_gold = player.stats.gold
    get_tree().change_scene_to_file(WIN_SCENE_PATH)


func _on_player_open_symbols_menu() -> void:
    const CELL_WIDTH = 55

    var symbols = [
        [Constants.PLAYER, "the hero"],
        [Constants.ARTIFACT, "the artifact"],
        [Constants.FLOOR, "the floor"],
        [Constants.STAIRS, "a stair case"],
        [Constants.WALL_V, "a wall"],
        [Constants.WALL_H, "a wall"],
        [Constants.WALL_CORNER_TL, "a corner"],
        [Constants.WALL_CORNER_BR, "a corner"],
        [Constants.WALL_CORNER_TR, "a corner"],
        [Constants.WALL_CORNER_BL, "a corner"],
        [Constants.CORRIDOR, "a passage"],
        [Constants.DOOR, "a door"],
        [Constants.WEAPON, "a weapon"],
        [Constants.ARMOR, "a piece of armor"],
        [Constants.HEALTH_POTION, "a potion of healing"],
        [Constants.STRENGTH_POTION, "a potion of strength"],
        [Constants.SCROLL, "a scroll"],
        [Constants.GOLD, "some gold"],
        ["a-z","different monsters"]
    ]

    var map_str = ""
    var i = 0
    while i < symbols.size():
        var row = ""
        print(i)
        var left = "%s: %s" % [symbols[i][0],symbols[i][1]]
        var right = ""
        if i+1 < symbols.size():
            right = "%s: %s" % [symbols[i+1][0],symbols[i+1][1]]
        row = left.rpad(CELL_WIDTH, " ") + right + "\n"
        map_str += row
        i+=2

    ui.set_stats_message("- Press space to continue -")
    level.text = map_str
