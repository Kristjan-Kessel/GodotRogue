extends Node
class_name Room

var grid_position: Vector2 = Vector2(0,0)
var position: Vector2 = Vector2(0,0)
var size: Vector2 = Vector2(0,0)
var tiles = []

var is_player_room = false
var is_exit_room = false
var skip = false
