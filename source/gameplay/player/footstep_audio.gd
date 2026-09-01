extends AudioStreamPlayer3D

@export_range(0.0, 1.0, 0.01) var volume_min: float = 1.0
@export_range(0.0, 1.0, 0.01) var volume_max: float = 1.0
@export_range(0.0, 1.0, 0.01) var pitch_min: float = 1.0
@export_range(1.0, 2.0, 0.01) var pitch_max: float = 1.0

var rng = RandomNumberGenerator.new()

func _on_footstep_timer_timeout() -> void:
	play_randomised_sound()

func play_randomised_sound():
	
	var random_volume = rng.randf_range(volume_min, volume_max)
	volume_linear = random_volume
	
	var random_pitch = rng.randf_range(pitch_min, pitch_max)
	pitch_scale = random_pitch
	
	play()
