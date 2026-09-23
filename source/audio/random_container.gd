extends AudioStreamPlayer3D
class_name RandomContainer

@export_range(0.0, 2.0, 0.01) var master_volume: float = 1.0
@export_range(0.0, 1.0, 0.01) var volume_min: float = 1.0
@export_range(0.0, 1.0, 0.01) var volume_max: float = 1.0
@export_range(0.0, 1.0, 0.01) var pitch_min: float = 1.0
@export_range(1.0, 2.0, 0.01) var pitch_max: float = 1.0
@export var audio_streams: Array[AudioStream] = []

var rng = RandomNumberGenerator.new()
var last_played_stream: AudioStream = null

func play_random():
	
	while stream == last_played_stream:
		stream = audio_streams.pick_random()
	last_played_stream = stream
	
	var random_volume = rng.randf_range(volume_min, volume_max) * master_volume
	volume_linear = random_volume
	
	var random_pitch = rng.randf_range(pitch_min, pitch_max)
	pitch_scale = random_pitch
	
	play()
