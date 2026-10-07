extends Node

var player_damage_modifier : int = 1
var paused: bool = false

signal Pause

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		Pause.emit()
		toggle_pause()

func toggle_pause():
	if !paused:
		paused = true
	elif paused:
		paused = false
