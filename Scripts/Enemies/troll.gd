extends Enemy

# Orc

func _ready() -> void:
    health = 25
    armor = 2
    attack = 20
    label = "Troll"
    ascii = Constants.TROLL
    min_exp = 2
    max_exp = 3
