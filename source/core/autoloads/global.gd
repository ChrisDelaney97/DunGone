extends Node

var player_damage_modifier : int = 1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
