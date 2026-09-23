extends Node3D

@onready var footstep: AudioStreamPlayer3D = $Footstep
@onready var jump: RandomContainer = $Jump
@onready var land: RandomContainer = $Land

func play_footstep():
	footstep.play_random()

func play_jump():
	jump.play_random()

func play_land():
	land.play_random()
