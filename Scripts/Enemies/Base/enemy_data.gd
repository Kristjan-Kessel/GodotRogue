extends Node
class_name EnemyData

var position: Vector2
var path: String
var is_sleeping: bool

func _init(_position, _path, _is_sleeping) -> void:
    path = _path
    position = _position
    is_sleeping = _is_sleeping
