extends Node
class_name WeaponController

@onready var primary_cooldown: Timer = $PrimaryCooldown
@onready var secondary_cooldown: Timer = $SecondaryCooldown
@onready var primary_cooldown_bar: Control = %HUD.get_node("PrimaryCooldownBar")
@onready var secondary_cooldown_bar: Control = %HUD.get_node("SecondaryCooldownBar")

@export var player: Player
@export var primary_weapon: Weapon
@export var secondary_weapon: Weapon
@export var weapon_model_parent: Node3D

var primary_cooldown_ready: bool = true
var secondary_cooldown_ready: bool = true
var current_weapon_model: Node3D
var current_weapon_anim: AnimationTree
var current_weapon_cast_spawn: Node3D

var current_weapon: Weapon

func _ready() -> void:
	if primary_weapon: current_weapon = primary_weapon
	# # # # # # # # if current_weapon: spawn_weapon_model()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("primary_action") and primary_cooldown_ready: primary_action()
	if event.is_action_pressed("secondary_action") and secondary_cooldown_ready: secondary_action()
	# # # # # # # if event.is_action_pressed("swap_weapon") and primary_weapon != null and secondary_weapon != null: swap_weapon()

func _process(delta: float) -> void:
	if !primary_cooldown.is_stopped():
		primary_cooldown_bar.value = ((primary_cooldown.wait_time-primary_cooldown.time_left)/primary_cooldown.wait_time) * 100
	if !secondary_cooldown.is_stopped():
		secondary_cooldown_bar.value = ((secondary_cooldown.wait_time-secondary_cooldown.time_left)/secondary_cooldown.wait_time) * 100

func spawn_weapon_model():
	if current_weapon_model:
		current_weapon_model.queue_free()
	
	if current_weapon.model:
		current_weapon_model = current_weapon.model.instantiate()
		current_weapon_anim = current_weapon_model.find_child("AnimationTree")
		current_weapon_cast_spawn = current_weapon_model.find_child("CastSpawn")
		current_weapon_model.stats = current_weapon
		weapon_model_parent.add_child(current_weapon_model)
		current_weapon_model.position = current_weapon.position
		current_weapon_anim["parameters/equip/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func _on_primary_cooldown_timeout() -> void:
	primary_cooldown_ready = true

func _on_secondary_cooldown_timeout() -> void:
	secondary_cooldown_ready = true

func primary_action():
	if current_weapon:
		current_weapon.primary_action(player, current_weapon_anim, current_weapon_cast_spawn)
		primary_cooldown_ready = false
		primary_cooldown.start(current_weapon.primary_action_cooldown)
	
func secondary_action():
	if current_weapon:
		current_weapon.secondary_action(player, current_weapon_anim, current_weapon_cast_spawn)
		secondary_cooldown_ready = false
		secondary_cooldown.start(current_weapon.secondary_action_cooldown)

func swap_weapon():
	if primary_weapon and secondary_weapon:
		if current_weapon == primary_weapon: current_weapon = secondary_weapon
		elif current_weapon == secondary_weapon: current_weapon = primary_weapon
		spawn_weapon_model()
