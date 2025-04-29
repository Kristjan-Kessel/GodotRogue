extends Enemy

# Drake

func _ready() -> void:
    health = 20
    armor = 6
    attack = 20
    label = "Drake"
    ascii = Constants.DRAKE
    min_exp = 1
    max_exp = 3
