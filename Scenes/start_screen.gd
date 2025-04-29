extends Node2D

const MAIN_SCENE_PATH := "res://Scenes/Main.tscn"
const LABEL_TEXT := "Rogue's name? "

var player_name := ""
var show_cursor := true

@onready var label = $UI/Background/Panel/InputLabel
@onready var cursor_timer := Timer.new()

func _ready():
    label.text = LABEL_TEXT
    add_child(cursor_timer)
    cursor_timer.wait_time = 0.5
    cursor_timer.autostart = true
    cursor_timer.one_shot = false
    cursor_timer.connect("timeout", _on_cursor_timer_timeout)
    cursor_timer.start(0.5)
    update_label()

func _input(event):
    if Input.is_action_just_pressed("enter"):
        start_game()
        return
    if Input.is_action_just_pressed("backspace"):
        if player_name.length() > 0:
            player_name = player_name.substr(0, player_name.length() - 1)
            update_label()
    if event is InputEventKey and event.pressed and not event.echo:
        var c = event.unicode
        if c >= 32 and c <= 126:
            player_name += char(c)
        update_label()

func update_label():
    var cursor = "_" if show_cursor else " "
    label.text = LABEL_TEXT + player_name + cursor

func _on_cursor_timer_timeout():
    show_cursor = !show_cursor
    update_label()

func start_game():
    Globals.player_name = player_name
    get_tree().change_scene_to_file(MAIN_SCENE_PATH)
