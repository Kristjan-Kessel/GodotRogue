extends Node

signal player_death

@export var level: int = 1
@export var max_hp: int = 12
@export var current_hp: int = 12 : set = _set_current_hp
@export var strength: int = 16
@export var armor: int = 5
@export var gold: int = 0
@export var exp: int = 0 : set = _set_current_exp
@export var player_lvl: int = 1

var bonus_armor = 0

func _set_current_exp(new_exp):
    exp = new_exp
    if exp > player_lvl*10:
        player_lvl += 1
        max_hp = max_hp + Globals.rng.randi_range(2,10)
        current_hp = max_hp

func _set_current_hp(new_hp):
    current_hp = clamp(new_hp,0,max_hp)
    if current_hp == 0:
        player_death.emit()

func get_total_armor():
    return armor+bonus_armor
    
func get_attack():
    return (strength-10)/2
