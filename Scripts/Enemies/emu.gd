extends Enemy

# Emu

func _ready() -> void:
    health = 1
    armor = 1
    attack = 10
    label = "Emu"
    ascii = Constants.EMU
    min_exp = 1
    max_exp = 1
