extends Node3D

@onready var arms_anchor: Marker3D = $"../CameraController/ArmsAnchor"

func anim_relax():
	$AnimationPlayer.play("ArmsRig|relax")

func anim_attack():
	$AnimationPlayer.play("ArmsRig|jab_R")

func anim_grab():
	$AnimationPlayer.play("ArmsRig|grab_R")

func anim_cast():
	$AnimationPlayer.play("ArmsRig|push_L")

func _process(_delta: float) -> void:
	global_transform = arms_anchor.get_global_transform_interpolated()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	anim_relax()
