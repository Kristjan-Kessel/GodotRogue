extends Node

signal action_taken()
signal player_move(new_position)

var ascii = Constants.PLAYER

# Movement variables
var position : Vector2 = Vector2.ZERO
var move_direction = Vector2.ZERO
var is_moving = false
var move_delay_timer = 0.0
var move_repeat_timer = 0.0
const INITIAL_MOVE_DELAY = 0.3
const REPEAT_RATE = 0.1

# Player stats
var level = 1
var max_hp = 12
var current_hp = 12 : set = _set_current_hp
var strength = 10
var armor = 10
var gold = 0
var current_exp = 0 : set = _set_current_exp
var max_exp = 1

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


func move_player():
	if move_direction != Vector2.ZERO:
		player_move.emit(position + move_direction)
