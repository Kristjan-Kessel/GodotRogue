extends "res://Scripts/item.gd"
class_name Armor

var armor_bonus: int

func _init(_label: String, _description: String, _ascii: String, _armor_bonus: int):
	label = _label
	description = _description
	ascii = _ascii
	armor_bonus = _armor_bonus
	type = Type.ARMOR
