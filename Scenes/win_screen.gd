extends Node2D

@onready var goldtext = $UI/Background/VBoxContainer/Gold

func _ready() -> void:
    goldtext = "%d gold" % Globals.final_gold
