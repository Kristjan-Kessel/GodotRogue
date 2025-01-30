class_name Tile
extends Node

var type: String
var walkable: bool
var entity: Node = null
var ascii: String

func _init(tile_type: String, is_walkable: bool, _ascii: String):
	type = tile_type
	walkable = is_walkable
	ascii = _ascii
