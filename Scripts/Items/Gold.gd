extends Item
class_name Gold

func _init():
    label = "Gold"
    description = ""
    ascii = Constants.GOLD

func on_pickup(player: Node, tile: Tile) -> String:
    var amount = Globals.rng.randi_range(5,40)
    player.stats.gold = player.stats.gold+amount
    type = Type.GOLD
    return "you picked up %d %s" % [amount,label]
