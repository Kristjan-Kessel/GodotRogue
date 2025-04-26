extends Item
class_name Gold

func _init():
    label = "Gold"
    description = ""
    ascii = Constants.GOLD

func on_pickup(player: Node, tile: Tile):
    player.stats.gold = player.stats.gold+1
    type = Type.GOLD
