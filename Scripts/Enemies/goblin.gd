extends Enemy

# Goblin

func _ready() -> void:
    health = 10
    armor = 2
    attack = 8
    label = "Goblin"
    ascii = Constants.GOBLIN
    min_exp = 1
    max_exp = 2
