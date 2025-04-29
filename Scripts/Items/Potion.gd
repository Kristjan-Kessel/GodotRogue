extends Item
class_name Potion

func _init():
    label = "Potion of Healing"
    description = "Restores 10 health when drunk"
    type = Type.USEABLE
    ascii = Constants.HEALTH_POTION

func on_use(player: Node):
    player.stats.current_hp += 10
