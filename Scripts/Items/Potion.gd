extends Item
class_name Potion

func _init():
    label = "Potion of Healing"
    description = "Heals you to full health when drank"
    type = Type.USEABLE

func on_use(player: Node):
    player.stats.current_hp = 100
