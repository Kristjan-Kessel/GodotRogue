extends Entity
class_name Enemy

@export var health: int
@export var armor: int
@export var strength: int

func on_turn():
	print("%s: my turn! i have %d health" % [label,health])
