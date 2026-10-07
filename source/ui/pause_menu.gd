extends Control

func _ready() -> void:
	Global.Pause.connect(toggle_pause_menu)

func _on_resume_pressed() -> void:
	visible = false
	toggle_pause_menu()
	Global.toggle_pause()

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()

func toggle_pause_menu() -> void:
	if !Global.paused:
		visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Global.paused:
		visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
