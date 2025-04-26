class_name Item
extends Node

enum Type {ITEM, WEAPON, ARMOR, GOLD, USEABLE}

var label: String
var description: String
var ascii = Constants.ITEM
var type: Type = Type.ITEM

func _init(_label: String, _description: String):
    label = _label
    description = _description

func on_pickup(player: Node, tile: Tile) -> String:
    player.inventory.append(self)
    return "you picked up "+label

func on_use(player: Node):
    pass
