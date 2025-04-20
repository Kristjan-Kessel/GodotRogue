extends Node

signal player_death

@export var level: int = 1
@export var max_hp: int = 12
@export var current_hp: int = 12 : set = _set_current_hp
@export var strength: int = 10
@export var armor: int = 10
@export var gold: int = 0
@export var current_exp: int = 0 : set = _set_current_exp
@export var max_exp: int = 1

var bonus_armor = 0

func _set_current_exp(new_exp):
	current_exp = new_exp
	if(new_exp >= max_exp):
		# level up
		level += 1
		current_exp -= max_exp
		max_exp += 1

func _set_current_hp(new_hp):
	current_hp = clamp(new_hp,0,max_hp)
	if current_hp == 0:
		player_death.emit()

func get_total_armor():
	return armor+bonus_armor
	
func get_attack():
	return (strength-10)/2
