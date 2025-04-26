extends Node
class_name Room

var grid_position: Vector2 = Vector2(0,0)
var position: Vector2 = Vector2(0,0)
var size: Vector2 = Vector2(0,0)
var tile_grid = [] #y,x

var is_player_room = false
var is_exit_room = false
var skip = false

func get_tile(position: Vector2) -> Tile:
    return tile_grid[position.y][position.x]

func print_info():
    for row in tile_grid:
        var msg = ""
        for tile in row:
            msg = msg+tile.ascii
        print(msg)

func get_center_tile() -> Tile:
    var y = tile_grid.size()/2
    var x = tile_grid[y].size()/2
    return get_tile(Vector2(x,y))
