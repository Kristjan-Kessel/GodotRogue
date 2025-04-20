extends Entity
class_name Enemy

signal enemy_move(new_position)

@export var health: int
@export var armor: int
@export var strength: int
@export var dice: int
enum State {IDLE,ATTACKING}
var state = ""

func on_turn(astar: AStar2D, tile: Tile, player_tile: Tile):
	# check if see player, turn to attacking stance!
	# move towards player
	var path = astar.get_point_path(player_tile.id, tile.id)
	enemy_move.emit(path[1], self)

func attack_player(player: Node) -> String:
	var hit = Globals.rng.randi_range(1,20)
	var crit = hit == 20
	var hit_bonus = (strength-10)/2
	print("hit: %d+%d" % [hit, hit_bonus])
	hit += hit_bonus
	
	if hit>=player.stats.armor || crit:
		var damage = Globals.rng.randi_range(1,dice)
		print("dmg: %d+%d" % [damage,hit_bonus])
		damage += hit_bonus
		player.stats.current_hp -= damage
		if crit:
			damage += damage
			return "The %s has injured you." % label
		else:
			return "The %s has greatly injured you." % label
	else:
		return "The %s misses you." % label
