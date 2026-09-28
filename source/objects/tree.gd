extends Node3D
class_name PineTree

@onready var foliage_sfx: AudioStreamPlayer3D = $FoliageSFX
var player: Player

func _process(delta: float) -> void:
	if !player:
		return
	else:
		if player.moving and !foliage_sfx.playing:
			print("start foliage sounds")
		if !player.moving and foliage_sfx.playing:
			print("stop foliage sounds")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		player = body

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		player = null
