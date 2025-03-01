class_name Tile
extends Node

var type: String
var is_walkable: bool
var entity: Node = null
var ascii: String
var is_important: bool

func _init(tile_type: String, _is_walkable: bool, _ascii: String, _important: bool):
	type = tile_type
	is_walkable = _is_walkable
	ascii = _ascii
	is_important = _important
