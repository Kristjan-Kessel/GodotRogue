extends Enemy

# Orc

func _ready() -> void:
    health = 15
    armor = 5
    attack = 14
    label = "Orc"
    ascii = Constants.ORC
    min_exp = 2
    max_exp = 3
