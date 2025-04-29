extends Enemy

# Banshee

func _ready() -> void:
    health = 1
    armor = 15
    attack = 30
    label = "Banshee"
    ascii = Constants.BANSHEE
    min_exp = 1
    max_exp = 3
