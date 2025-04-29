extends Entity

signal action_taken()
signal player_move(new_position)
signal log_message(new_message)
signal command_find(direction)
signal open_inventory(text, items)
signal render_map()
signal drop_item(item)
signal open_help_menu()
signal use_stairs()
signal player_death()
signal win()

# Movement variables
var move_direction = Vector2.ZERO
var is_moving = false
var move_delay_timer = 0.0
var move_repeat_timer = 0.0
const INITIAL_MOVE_DELAY = 0.3
const REPEAT_RATE = 0.1
var action_delay_timer = 0.0

@onready var stats = $Stats

# Commands
enum CommandType {DEATH, INSPECT, NONE, FIND, MOVE, INVENTORY, HELP, DROP, WEAR_ARMOR, WIELD_WEAPON, USE_ITEM, ATTACK} # For commands that take an argument to execute (ex: direction)
var current_command = CommandType.NONE

# Inventory
var inventory = []
var armor_item = null
var weapon_item = null

var stunned = false

func _ready() -> void:
    ascii = Constants.PLAYER
    
    #inventory.append(Item.new("Totem of debugging","Used to test if the inventory is functioning correctly"))
    var start_weapon = Weapon.new("Dagger","Just a dagger with a damage dice of 6",0,6)
    inventory.append(start_weapon)
    weapon_item = start_weapon
    var start_armor = Armor.new("Leather armor","Just some leather armor with an armor class of 5",5)
    inventory.append(start_armor)
    armor_item = start_armor
 
func _process(delta: float) -> void:
    if action_delay_timer > 0.0:
        action_delay_timer -= delta
        return
    
    if current_command == CommandType.DEATH:
        if Input.is_action_just_pressed("continue"):
            player_death.emit()
    
    if stunned:
        if Input.is_action_just_pressed("continue"):
                current_command = CommandType.MOVE
                log_message.emit("")
                stunned = false
                action_taken.emit()
                return
    
    if Input.is_action_just_pressed("command_cancel"):
        current_command = CommandType.NONE
        log_message.emit("")
        render_map.emit()
        return
    
    match current_command:
        CommandType.DROP:
            if Input.is_action_just_pressed("view_options"):
                open_inventory.emit("- Select an item to drop -",inventory)
            else:	
                var item = get_item_from_key()
                if item != null:
                    drop_item.emit(item)
            return
        CommandType.INSPECT:
            if Input.is_action_just_pressed("view_options"):
                open_inventory.emit("- Select an item to inspect -",inventory)
            else:	
                var item = get_item_from_key()
                if item != null:
                    var item_info = "%s, %s" % [item.label, item.description]
                    log_message.emit(item_info)
            return
        CommandType.USE_ITEM:
            if Input.is_action_just_pressed("view_options"):
                var valid_items = inventory.filter(func(item) -> bool:
                    return item.type == item.Type.USEABLE
                )
                if valid_items.size() == 0:
                    log_message.emit("No items to use.")
                    clear_command()
                    return
                open_inventory.emit("- Select an item to use -", valid_items)
            else:	
                var item = get_item_from_key()
                if item != null:
                    if item.type == item.Type.USEABLE:
                        log_message.emit("Used "+item.label)
                        item.on_use(self)
                        inventory.erase(item)
                    else:
                        log_message.emit("Invalid item.")
                        current_command = CommandType.NONE
                    render_map.emit()
            return
        CommandType.WEAR_ARMOR:
            if Input.is_action_just_pressed("view_options"):
                var valid_items = inventory.filter(func(item) -> bool:
                    return item.type == item.Type.ARMOR
                )
                if valid_items.size() == 0:
                    log_message.emit("No armor to wear.")
                    clear_command()
                    return
                open_inventory.emit("- Select an item to wear as armor -",valid_items)
            else:	
                var item = get_item_from_key()
                if item != null:
                    if item.type == item.Type.ARMOR:
                        if item == armor_item:
                            log_message.emit("You are already wearing that.")
                            current_command = CommandType.NONE
                            return
                        armor_item = item
                        stats.armor_class = armor_item.armor_class
                        log_message.emit("Wore "+item.label+" as armor.")
                    else:
                        log_message.emit("Invalid item.")
                    current_command = CommandType.NONE
                    render_map.emit()
            return
        CommandType.WIELD_WEAPON:
            if Input.is_action_just_pressed("view_options"):
                var valid_items = inventory.filter(func(item) -> bool:
                    return item.type == item.Type.WEAPON
                )
                if valid_items.size() == 0:
                    log_message.emit("No weapons to wield.")
                    clear_command()
                    return
                open_inventory.emit("- Select an item to wield as a weapon -", valid_items)
            else:	
                var item = get_item_from_key()
                if item != null:
                    if item.type == item.Type.WEAPON:
                        if item == weapon_item:
                            log_message.emit("You are already wielding that.")
                            current_command = CommandType.NONE
                            return
                        weapon_item = item
                        log_message.emit("Wielded "+item.label+" as a weapon.")
                    else:
                        log_message.emit("Invalid item.")
                    current_command = CommandType.NONE
                    render_map.emit()
            return
        CommandType.INVENTORY:
            if Input.is_action_just_pressed("continue"):
                current_command = CommandType.NONE
                render_map.emit()
        CommandType.HELP:
            if Input.is_action_just_pressed("continue"):
                current_command = CommandType.NONE
                render_map.emit()
        CommandType.MOVE:
            var new_direction = Vector2.ZERO
        
            if Input.is_action_pressed("ui_up"):
                new_direction = Vector2(0, -1)
            elif Input.is_action_pressed("ui_down"):
                new_direction = Vector2(0, 1)
            elif Input.is_action_pressed("ui_left"):
                new_direction = Vector2(-1, 0)
            elif Input.is_action_pressed("ui_right"):
                new_direction = Vector2(1, 0)

            # Lets you move one tile at a time, or keep moving if you keep holding the key.
            if new_direction != Vector2.ZERO:
                if !is_moving || new_direction != move_direction:
                    move_direction = new_direction
                    is_moving = true
                    move_delay_timer = INITIAL_MOVE_DELAY
                    move_repeat_timer = 0.0
                    move_player()
                elif is_moving:
                    move_delay_timer -= delta
                    if move_delay_timer <= 0:
                        move_repeat_timer -= delta
                        if move_repeat_timer <= 0:
                            move_player()
                            move_repeat_timer = REPEAT_RATE
            elif is_moving:
                is_moving = false
        CommandType.FIND:
            var direction = Vector2.ZERO
            if Input.is_action_just_pressed("ui_up"):
                direction = Vector2(0, -1)
            elif Input.is_action_just_pressed("ui_down"):
                direction = Vector2(0, 1)
            elif Input.is_action_just_pressed("ui_left"):
                direction = Vector2(-1, 0)
            elif Input.is_action_just_pressed("ui_right"):
                direction = Vector2(1, 0)
            elif Input.is_action_just_pressed("command_find"):
                current_command = CommandType.NONE
                log_message.emit("")

            if direction != Vector2.ZERO:
                command_find.emit(direction)
                clear_command()
        CommandType.ATTACK:
            if Input.is_action_just_pressed("continue"):
                current_command = CommandType.MOVE
                log_message.emit("")
                action_taken.emit()
                return
    if current_command == CommandType.NONE || current_command == CommandType.MOVE:
        if Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("ui_down") || Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("ui_right"):  
            current_command = CommandType.MOVE
        if Input.is_action_just_pressed("command_find"):
            current_command = CommandType.FIND
            log_message.emit("Choose a direction to look")
        elif Input.is_action_just_pressed("command_rest"):
            action_taken.emit()
            delay_actions(0.1)
        elif Input.is_action_just_pressed("command_inventory"):
            current_command = CommandType.INVENTORY
            open_inventory.emit("- Press space to continue -", inventory)
        elif Input.is_action_just_pressed("command_drop"):
            current_command = CommandType.DROP
            log_message.emit("Choose an item to drop (a-z). press (*) to view options")
        elif Input.is_action_just_pressed("command_inspect"):
            current_command = CommandType.INSPECT
            log_message.emit("Choose an item to inspect (a-z). press (*) to view options")
        elif Input.is_action_just_pressed("command_wear_armor"):
            if armor_item != null:
                log_message.emit("You're already wearing armor.")
            else:
                current_command = CommandType.WEAR_ARMOR
                log_message.emit("Choose an item to wear as armor (a-z). press (*) to view options")
        elif Input.is_action_just_pressed("command_wield_weapon"):
            current_command = CommandType.WIELD_WEAPON
            log_message.emit("Choose an item to wield as a weapon (a-z). press (*) to view options")
        elif Input.is_action_just_pressed("command_take_armor_off"):
            if armor_item != null:
                armor_item = null
                log_message.emit("Took off armor.")
                stats.armor_class = 1
                render_map.emit()
            else:
                log_message.emit("No armor to take off.")
            delay_actions(0.1)
        elif Input.is_action_just_pressed("command_use_item"):
            current_command = CommandType.USE_ITEM
            log_message.emit("Choose an item to use (a-z). press (*) to view options")
        elif Input.is_action_just_pressed("command_help"):
            current_command = CommandType.HELP
            open_help_menu.emit()
        elif Input.is_action_just_pressed("command_stairs"):
            use_stairs.emit()
            delay_actions(0.1)

func delay_actions(delay: float):
    action_delay_timer = delay

func clear_command():
    delay_actions(0.1)
    current_command = CommandType.NONE

func move_player():
    if move_direction != Vector2.ZERO:
        player_move.emit(position + move_direction)

func attack_enemy(enemy: Enemy):
    current_command = CommandType.ATTACK
    var hit = Globals.rng.randi_range(1,weapon_item.dice)
    var crit = hit == weapon_item.dice
    var hit_bonus = weapon_item.bonus_attack + stats.get_attack_bonus()
    hit += hit_bonus
    hit = hit - enemy.armor
    if hit>0:
        enemy.health -= hit
        if crit:
            log_message.emit("You scored an excellent hit on the %s. [continue]" % enemy.label)	
        else:
            log_message.emit("You scored a hit on the %s. [continue]" % enemy.label)	
    else:
        log_message.emit("You missed the %s. [continue]" % [enemy.label])

func get_item_from_key() -> Item:
    for c in Constants.INVENTORY_CHARS:
        if Input.is_key_pressed(OS.find_keycode_from_string(c)):
            var index = Constants.INVENTORY_CHARS.find(c)
            current_command = CommandType.NONE
            render_map.emit()
            if index < inventory.size():
                var item = inventory[index]
                #drop_item.emit(item)
                return item
            else:
                log_message.emit("Invalid item.")
    return null

func _on_stats_player_death() -> void:
    current_command = CommandType.DEATH
