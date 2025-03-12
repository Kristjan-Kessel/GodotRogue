extends "res://Scripts/item.gd"
class_name Gold

func _init():
	label = "Gold"
	description = ""
	ascii = Constants.GOLD

func on_pickup(player: Node, tile: Tile):
	player.gold = player.gold+1
