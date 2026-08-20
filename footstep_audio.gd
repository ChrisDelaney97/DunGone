extends AudioStreamPlayer3D

var rng = RandomNumberGenerator.new()

func _on_footstep_timer_timeout() -> void:
	play_sound()

func play_sound():
	
	var random_volume = rng.randf_range(0.9, 0.95)
	volume_linear = random_volume
	
	var random_pitch = rng.randf_range(0.93, 1.07)
	pitch_scale = random_pitch
	
	play()
