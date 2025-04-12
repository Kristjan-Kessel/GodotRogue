class_name Item
extends Node

enum Type {ITEM, WEAPON, ARMOR, GOLD, CONSUMABLE}

var label: String
var description: String
var ascii: String
var type: Type = Type.ITEM

func _init(_label: String, _description: String, _ascii: String):
	label = _label
	description = _description
	ascii = _ascii

func on_pickup(player: Node, tile: Tile):
	player.inventory.append(self)
