extends Node

signal action_taken()
signal player_move(new_position)
signal log_message(new_message)
signal command_find(direction)
signal open_inventory(text)
signal render_map()
signal drop_item(item)

var ascii = Constants.PLAYER

# Movement variables
var position : Vector2 = Vector2.ZERO
var move_direction = Vector2.ZERO
var is_moving = false
var move_delay_timer = 0.0
var move_repeat_timer = 0.0
const INITIAL_MOVE_DELAY = 0.3
const REPEAT_RATE = 0.1
var action_delay_timer = 0.0

var stats = Stats.new(1,12,10,10,0)

# Commands
enum CommandType {NONE, FIND, MOVE, INVENTORY, DROP, WEAR_ARMOR, WIELD_WEAPON, USE_ITEM} # For commands that take an argument to execute (ex: direction)
var current_command = CommandType.NONE

# Inventory
var inventory = []
var armor_item = null
var weapon_item = Weapon.new("Dagger","Just a basic dagger",1)

func _ready() -> void:
	inventory.append(Item.new("Totem of debugging","Used to test if the inventory is functioning correctly"))
	inventory.append(Weapon.new("Sword +1","Grants +1 to damage and hit",1))
	inventory.append(Armor.new("Armor +1","Grants +1 to armor",1))
	inventory.append(Potion.new())
func _process(delta: float) -> void:
	if action_delay_timer > 0.0:
		action_delay_timer -= delta
		return
	
	if current_command == CommandType.DROP:
		if Input.is_action_just_pressed("view_options"):
			open_inventory.emit("- Select an item to drop -")
		else:	
			var item = get_item_from_key()
			if item != null:
				drop_item.emit(item)
		return
	elif current_command == CommandType.USE_ITEM:
		if Input.is_action_just_pressed("view_options"):
			open_inventory.emit("- Select an item to use -")
		else:	
			var item = get_item_from_key()
			if item != null:
				if item.type == item.Type.USEABLE:
					item.on_use(self)
					inventory.erase(item)
					log_message.emit("Used "+item.label)
				else:
					log_message.emit("Invalid item.")
					current_command = CommandType.NONE
				render_map.emit()
		return
		return
	elif current_command == CommandType.WEAR_ARMOR:
		if Input.is_action_just_pressed("view_options"):
			open_inventory.emit("- Select an item to wear as armor -")
		else:	
			var item = get_item_from_key()
			if item != null:
				if item.type == item.Type.ARMOR:
					if armor_item != null:
						inventory.append(armor_item)
					armor_item = item
					stats.bonus_armor = armor_item.armor_bonus
					inventory.erase(item)
					log_message.emit("Wore "+item.label+" as armor.")
				else:
					log_message.emit("Invalid item.")
					current_command = CommandType.NONE
				render_map.emit()
		return
	elif current_command == CommandType.WIELD_WEAPON:
		if Input.is_action_just_pressed("view_options"):
			open_inventory.emit("- Select an item to wield as a weapon -")
		else:	
			var item = get_item_from_key()
			if item != null:
				if item.type == item.Type.WEAPON:
					if weapon_item != null:
						inventory.append(weapon_item)
					weapon_item = item
					stats.bonus_strength = weapon_item.strength_bonus
					inventory.erase(item)
					log_message.emit("Wielded "+item.label+" as a weapon.")
				else:
					log_message.emit("Invalid item.")
					current_command = CommandType.NONE
				render_map.emit()
		return
	elif current_command == CommandType.INVENTORY:
		if Input.is_action_just_pressed("continue"):
			current_command = CommandType.NONE
			render_map.emit()
	elif current_command == CommandType.MOVE:
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
	elif current_command == CommandType.FIND:
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
			open_inventory.emit("- Press space to continue -")
		elif Input.is_action_just_pressed("command_drop"):
			current_command = CommandType.DROP
			log_message.emit("Choose an item to drop (a-z). press (*) to view options")
		elif Input.is_action_just_pressed("command_wear_armor"):
			current_command = CommandType.WEAR_ARMOR
			log_message.emit("Choose an item to wear as armor (a-z). press (*) to view options")
		elif Input.is_action_just_pressed("command_wield_weapon"):
			current_command = CommandType.WIELD_WEAPON
			log_message.emit("Choose an item to wield as a weapon (a-z). press (*) to view options")
		elif Input.is_action_just_pressed("command_take_armor_off"):
			if armor_item != null:
				inventory.append(armor_item)
				armor_item = null
				log_message.emit("Took off armor.")
				stats.bonus_armor = 0
				render_map.emit()
			else:
				log_message.emit("No armor to take off.")
			delay_actions(0.1)
		elif Input.is_action_just_pressed("command_use_item"):
			current_command = CommandType.USE_ITEM
			log_message.emit("Choose an item to use (a-z). press (*) to view options")
func delay_actions(delay: float):
	action_delay_timer = delay

func clear_command():
	delay_actions(0.1)
	current_command = CommandType.NONE

func move_player():
	if move_direction != Vector2.ZERO:
		player_move.emit(position + move_direction)

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
