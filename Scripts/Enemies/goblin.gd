extends Enemy

# Goblin

func _ready() -> void:
    health = 10
    armor = 2
    attack = 8
    label = "Goblin"
    ascii = "[color=#1f7d00]g[/color]"
    min_exp = 1
    max_exp = 2
