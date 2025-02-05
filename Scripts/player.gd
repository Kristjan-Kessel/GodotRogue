extends Node

signal action_taken()
signal player_move(new_position)

var position : Vector2 = Vector2.ZERO
var ascii = Constants.PLAYER

var level = 1
var max_hp = 12
var current_hp = 12 : set = _set_current_hp
var strength = 10
var armor = 10
var gold = 0
var current_exp = 0
var max_exp = 1

func _set_current_hp(new_hp):
	current_hp = clamp(new_hp,0,max_hp)

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	var move_direction = Vector2.ZERO;
	if Input.is_action_just_pressed("ui_up"):
		move_direction = Vector2(0, -1)
	elif Input.is_action_just_pressed("ui_down"):
		move_direction = Vector2(0, 1)
	elif Input.is_action_just_pressed("ui_left"):
		move_direction = Vector2(-1, 0)
	elif Input.is_action_just_pressed("ui_right"):
		move_direction = Vector2(1, 0)
	else:
		return
	
	player_move.emit(position+move_direction)
