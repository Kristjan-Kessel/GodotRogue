extends Item
class_name StrengthPotion

func _init():
    label = "Potion of Strength"
    description = "Grants you +1 to strength"
    type = Type.USEABLE
    ascii = Constants.STRENGTH_POTION

func on_use(player: Node):
    player.stats.strength += 1
