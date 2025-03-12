extends Control

@onready var stats_label = $StatsLabel
@onready var log_label = $LogLabel

func update_stats(ps):
	stats_label.text = "Level:%d Hits:%d(%d) Str:%d Gold:%d Armor:%d exp:%d/%d" % [ps.level, ps.current_hp, ps.max_hp, ps.strength, ps.gold, ps.armor, ps.current_exp, ps.max_exp]

func set_stats_message(message):
	stats_label.text = message

func set_log_message(message):
	log_label.text = message
