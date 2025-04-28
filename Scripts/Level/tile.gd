class_name Tile
extends Node

var type: String
var is_walkable: bool
var entity: Node = null
var item: Node = null
var ascii: String
var is_important: bool
var id: int
var discovered = false
var position: Vector2

func _init(tile_type: String, _is_walkable: bool, _ascii: String, _important: bool, _position: Vector2):
    type = tile_type
    is_walkable = _is_walkable
    ascii = _ascii
    is_important = _important
    position = _position
    id = position.y * Constants.map_width + position.x
    
func is_interesting() -> bool:
    return is_important || item != null || entity != null
