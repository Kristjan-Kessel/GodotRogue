extends Node

signal action_taken()
signal player_move(new_position)
signal log_message(new_message)
signal command_find(direction)
signal open_inventory()
signal close_menu()

var ascii = Constants.PLAYER

# Movement variables
var position : Vector2 = Vector2.ZERO
var move_direction = Vector2.ZERO
var is_moving = false
var move_delay_timer = 0.0
var move_repeat_timer = 0.0
const INITIAL_MOVE_DELAY = 0.3
const REPEAT_RATE = 0.1
var post_command_delay_timer = 0.0

# Player stats
var level = 1
var max_hp = 12
var current_hp = 12 : set = _set_current_hp
var strength = 10
var armor = 10
var gold = 0
var current_exp = 0 : set = _set_current_exp
var max_exp = 1

# Commands
enum CommandType {NONE, FIND, REST, MOVE, INVENTORY} # For commands that take an argument to execute (ex: direction)
var current_command = CommandType.NONE

# Inventory
var inventory = [Item.new("Totem of debugging","Used to test if the inventory is functioning correctly","*")]

func _set_current_exp(new_exp):
	current_exp = new_exp
	if(new_exp >= max_exp):
		#level up
		level+=1
		current_exp -= max_exp
		max_exp+=1

func _set_current_hp(new_hp):
	current_hp = clamp(new_hp,0,max_hp)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if post_command_delay_timer > 0.0:
		post_command_delay_timer -= delta
		if post_command_delay_timer <= 0.0:
			if current_command == CommandType.FIND:
				current_command = CommandType.MOVE
			else:
				current_command = CommandType.NONE
	
	if current_command == CommandType.INVENTORY:
		if Input.is_action_just_pressed("continue"):
			current_command = CommandType.NONE
			close_menu.emit()
	
	if current_command == CommandType.MOVE:
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
			current_command = CommandType.REST
			action_taken.emit()
			clear_command()
		elif Input.is_action_just_pressed("command_inventory"):
			current_command = CommandType.INVENTORY
			open_inventory.emit()

func clear_command():
	post_command_delay_timer = 0.1 

func move_player():
	if move_direction != Vector2.ZERO:
		player_move.emit(position + move_direction)
