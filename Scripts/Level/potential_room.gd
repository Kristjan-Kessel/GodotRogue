extends Node
class_name PotentialRoom

var x: int
var y: int

var is_player_room = false
var is_exit_room = false
var skip = false

func _init(_x: int, _y:int) -> void:
	x = _x
	y = _y
