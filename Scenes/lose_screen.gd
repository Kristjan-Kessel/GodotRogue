extends Node2D

@onready var player_name = $UI/Background/VBoxContainer/PlayerName
@onready var cause = $UI/Background/VBoxContainer/CauseOfDeath
@onready var daymonth = $UI/Background/VBoxContainer/DayMonth
@onready var year = $UI/Background/VBoxContainer/Year

func _ready() -> void:
    player_name.text = Globals.player_name
    cause.text = Globals.cause_of_death

    var current_date = Time.get_date_dict_from_system()

    var day = current_date.day
    var month = current_date.month
    var month_name = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"][month]
    daymonth.text = str(day) + ". " + month_name.to_lower()

    year.text = str(current_date.year)
