extends Enemy

# Centaur

func _ready() -> void:
    health = 20
    armor = 3
    attack = 14
    label = "Centaur"
    ascii = Constants.CENTAUR
    min_exp = 1
    max_exp = 3
