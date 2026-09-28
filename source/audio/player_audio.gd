extends Node3D
class_name AudioManager_Player

@onready var footstep: AudioStreamPlayer3D = $Footstep
@onready var jump: RandomContainer = $Jump
@onready var land: RandomContainer = $Land
@onready var footstep_switch_container: SwitchContainer = %FootstepSwitchContainer
@onready var ground_check: RayCast3D = %GroundCheck

func play_footstep():
	if ground_check.get_collider().is_in_group("ground"):
		var current_ground_mat = ground_check.get_collider().get_parent().get_active_material(0)
		var current_ground_type = current_ground_mat.surface_type
		var current_ground = current_ground_mat.SurfaceType.find_key(current_ground_type)
		footstep_switch_container.change_condition(current_ground)
		footstep_switch_container.play_switch_sound()

func play_jump():
	jump.play_random()

func play_land():
	land.play_random()
