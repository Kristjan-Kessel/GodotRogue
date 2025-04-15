extends Item
class_name Weapon

var bonus_attack: int
var dice: int

func _init(_label: String, _description: String, _bonus_attack: int, _dice: int):
	label = _label
	description = _description
	bonus_attack = _bonus_attack
	type = Type.WEAPON
	dice = _dice
