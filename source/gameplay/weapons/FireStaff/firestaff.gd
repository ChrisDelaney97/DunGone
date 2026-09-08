extends Node3D

@onready var cast_spawn: Node3D = %CastSpawn
const FIREBALL = preload("uid://bdw1ppxlns7ol")
var stats : Weapon

func spawn_fireball():
	var fireball = FIREBALL.instantiate()
	fireball.damage = stats.primary_action_damage
	fireball.position = cast_spawn.global_position
	fireball.transform.basis = cast_spawn.global_transform.basis
	get_tree().root.add_child(fireball)

func damage_buff():
	BuffManager.firestaff_buff()
