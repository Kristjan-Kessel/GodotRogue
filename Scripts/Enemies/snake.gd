extends Enemy

# Snake

func _ready() -> void:
    health = 6
    armor = 3
    attack = 8
    label = "Snake"
    ascii = Constants.SNAKE
    min_exp = 1
    max_exp = 2
