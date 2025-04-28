extends Node

signal player_death

@export var level: int = 1
@export var max_hp: int = 12
@export var current_hp: int = 12 : set = _set_current_hp
@export var strength: int = 14
@export var armor_class: int = 5
@export var gold: int = 0
@export var exp: int = 0 : set = _set_current_exp
@export var player_lvl: int = 1
@export var turns_until_regen = 13 : set = _set_current_regen
const turns_to_regen = 13

func _set_current_regen(new_turns):
    if current_hp == max_hp:
        turns_until_regen = turns_to_regen
        return
    turns_until_regen = new_turns
    if turns_until_regen == 0:
        turns_until_regen = turns_to_regen
        current_hp += 1

func _set_current_exp(new_exp):
    exp = new_exp
    if exp >= player_lvl*10:
        player_lvl += 1
        max_hp = max_hp + Globals.rng.randi_range(2,10)
        current_hp = max_hp

func _set_current_hp(new_hp):
    current_hp = clamp(new_hp,0,max_hp)
    if current_hp == 0:
        player_death.emit()
    
func get_attack_bonus():
    return (strength-10)/2
