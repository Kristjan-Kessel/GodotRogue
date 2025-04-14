class_name Stats
extends Node

var level: int = 1
var max_hp: int = 12
var current_hp: int = 12 : set = _set_current_hp
var strength: int = 10
var armor: int = 10
var gold: int = 0
var current_exp: int = 0 : set = _set_current_exp
var max_exp: int = 1

var bonus_armor = 0
var bonus_strength = 0

func _init(_level: int, _max_hp: int, _strength: int, _armor: int, _gold: int):
	level = _level
	max_hp = _max_hp
	current_hp = _max_hp
	strength = _strength
	armor = _armor
	gold = _gold

func _set_current_exp(new_exp):
	current_exp = new_exp
	if(new_exp >= max_exp):
		# level up
		level += 1
		current_exp -= max_exp
		max_exp += 1

func _set_current_hp(new_hp):
	current_hp = clamp(new_hp,0,max_hp)

func get_total_strength():
	return strength+bonus_strength

func get_total_armor():
	return armor+bonus_armor
