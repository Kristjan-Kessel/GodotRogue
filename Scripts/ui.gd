extends Control

@onready var stats_label = $StatsLabel
@onready var log_label = $LogLabel

func update_stats(hp, gold, level):
	stats_label.text = "HP: %d  Gold: %d  Level: %d" % [hp, gold, level]

func set_log_message(message):
	log_label.text = message
