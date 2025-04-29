extends Enemy

# Ice Monster

func _ready() -> void:
    health = 15
    armor = 5
    attack = 12
    label = "Ice Monster"
    ascii = Constants.ICE_MONSTER
    min_exp = 2
    max_exp = 3

func attack_effects(player: Node, message: String) -> String:
    player.stunned = true
    message = message+" You have been stunned."
    return message
