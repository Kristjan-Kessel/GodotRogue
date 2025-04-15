extends Node
class_name EnemyData

var position: Vector2
var path: String

func _init(_position, _path) -> void:
	path = _path
	position = _position
