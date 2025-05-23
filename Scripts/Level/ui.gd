extends Node

@onready var stats_label = $Background/StatsLabel

func update_stats(player, turn):
    stats_label.text = format_stats(player)

func set_stats_message(message):
    stats_label.text = message

func format_stats(player):
    var strength_bonus = ""
    
    var stats = player.stats

    if player.weapon_item.bonus_attack > 0:
        strength_bonus = "(+%d)" % player.weapon_item.bonus_attack

    return "Level:%d Hits:%d(%d) Str:%d%s Gold:%d Armor:%d exp:%d/%d" % [
        stats.level,
        stats.current_hp,
        stats.max_hp,
        stats.strength,
        strength_bonus,
        stats.gold,
        stats.armor_class,
        stats.player_lvl,
        stats.exp
    ]
