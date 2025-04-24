extends Entity
class_name Enemy

signal enemy_move(new_position)

@export var health: int
@export var armor: int
@export var attack: int
enum State {SLEEPING,IDLE,ATTACKING}
var state = State.ATTACKING
var is_visible = true

func on_turn(astar: AStar2D, tile: Tile, player_tile: Tile):
	if state == State.IDLE:
		#if see player then start attacking
		if true:
			state = State.ATTACKING
	if state == State.ATTACKING:
		var path = astar.get_point_path(player_tile.id, tile.id)
		enemy_move.emit(path[1], self)

func attack_player(player: Node) -> String:
	var hit = Globals.rng.randi_range(0,attack)
	var crit = hit == attack
	var result = ""
	
	if hit > player.stats.armor || crit:
		player.stats.current_hp -= hit - player.stats.armor
		if crit:
			result = "The %s has greatly injured you." % label	
		else:
			result = "The %s has injured you." % label
		if player.stats.current_hp == 0:
			result = "The %s has killed you." % label
	else:
		result = "The %s misses you." % label
	return result
