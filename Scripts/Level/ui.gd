extends Node

@onready var stats_label = $StatsLabel

func update_stats(ps):
	stats_label.text = format_stats(ps)

func set_stats_message(message):
	stats_label.text = message

func format_stats(stats):
	var strength_bonus = ""
	var armor_bonus = ""

	if stats.bonus_strength >= 1:
		strength_bonus = "(+%d)" % stats.bonus_strength

	if stats.bonus_armor >= 1:
		armor_bonus = "(+%d)" % stats.bonus_armor

	return "Level:%d Hits:%d(%d) Str:%d%s Gold:%d Armor:%d%s exp:%d/%d" % [
		stats.level,
		stats.current_hp,
		stats.max_hp,
		stats.strength,
		strength_bonus,
		stats.gold,
		stats.armor,
		armor_bonus,
		stats.current_exp,
		stats.max_exp
	]
