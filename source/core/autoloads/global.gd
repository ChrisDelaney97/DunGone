extends Node

var player_damage_modifier : int = 1
var paused: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		toggle_pause()

func toggle_pause():
	if !paused:
		paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# get_tree().paused = true
	elif paused:
		paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		# get_tree().paused = false
