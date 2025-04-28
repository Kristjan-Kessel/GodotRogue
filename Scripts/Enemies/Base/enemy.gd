extends Entity
class_name Enemy

signal enemy_move(new_position)

@export var health: int : set = _set_health
@export var armor: int
@export var attack: int
var min_exp: int
var max_exp: int
enum State {SLEEPING,IDLE,ATTACKING}
var state = State.IDLE
var is_visible = true
var can_see_player = false

func on_turn(path: Array, bypass_path: Array):
    if state == State.IDLE:
        if can_see_player:
            state = State.ATTACKING
    if state == State.ATTACKING:
        if path.size() > 0:
            enemy_move.emit(path[1], self)
        else:
            if bypass_path.size() > 0:
                enemy_move.emit(bypass_path[1], self)

func _set_health(hp: int):
    health = hp
    if state == State.SLEEPING:
        state = State.ATTACKING

func attack_player(player: Node) -> String:
    var hit = Globals.rng.randi_range(0,attack)
    var crit = hit == attack
    var result = ""
    
    if hit > player.stats.armor_class || crit:
        player.stats.current_hp -= hit - player.stats.armor_class
        if crit:
            result = "The %s has greatly injured you." % label	
        else:
            result = "The %s has injured you." % label
        if player.stats.current_hp == 0:
            result = "The %s has killed you." % label
            return result
        result = attack_effects(player,result)
    else:
        result = "The %s misses you." % label
    return result

func attack_effects(player: Node, message: String) -> String:
    return message
