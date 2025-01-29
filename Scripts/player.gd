extends Node

signal action_taken()
signal player_move(new_position)

var position : Vector2 = Vector2.ZERO

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var move_direction = Vector2.ZERO;
	if Input.is_action_just_pressed("ui_up"):
		move_direction = Vector2(0, -1)
	elif Input.is_action_just_pressed("ui_down"):
		move_direction = Vector2(0, 1)
	elif Input.is_action_just_pressed("ui_left"):
		move_direction = Vector2(-1, 0)
	elif Input.is_action_just_pressed("ui_right"):
		move_direction = Vector2(1, 0)
	else:
		return
	
	emit_signal("player_move", position+move_direction)
