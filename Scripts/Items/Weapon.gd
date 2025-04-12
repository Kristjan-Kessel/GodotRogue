extends "res://Scripts/item.gd"
class_name Weapon

var strength_bonus: int

func _init(_label: String, _description: String, _ascii: String, _strength_bonus: int):
	label = _label
	description = _description
	ascii = _ascii
	strength_bonus = _strength_bonus
	type = Type.WEAPON
