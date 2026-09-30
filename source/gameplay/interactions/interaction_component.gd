extends Node

enum InteractionType {
	DEFAULT,
	ITEM
}

@export var interaction_type: InteractionType = InteractionType.DEFAULT
@export var item_data: ItemData

var object_ref: Node3D
var can_interact: bool = true
var is_interacting: bool = false

var player_hand: Marker3D

# Signals
signal ItemCollected (item: Node)

func _ready() -> void:
	object_ref = get_parent()
	if item_data:
		var scene_path: String = get_parent().scene_file_path
		item_data.item_model_prefab = load(scene_path)

func pre_interact(hand:Marker3D) -> void:
	is_interacting = true
	match interaction_type:
		InteractionType.DEFAULT:
			player_hand = hand

func interact() -> void:
	if !can_interact:
		return
	match interaction_type:
		InteractionType.DEFAULT:
			carry()
		InteractionType.ITEM:
			collect_item()

func secondary_interact():
	if !can_interact:
		return
	match interaction_type:
		InteractionType.DEFAULT:
			throw()

func post_interact() -> void:
	is_interacting = false

func _input(_event: InputEvent) -> void:
	return

func carry() -> void:
	var object_current_position: Vector3 = object_ref.global_transform.origin
	var player_hand_position: Vector3 = player_hand.global_transform.origin
	var object_distance: Vector3 = player_hand_position - object_current_position
	
	var rigid_body_3d: RigidBody3D = object_ref as RigidBody3D
	if rigid_body_3d:
		rigid_body_3d.set_linear_velocity((object_distance) * (5/rigid_body_3d.mass))

func throw():
	var object_current_position: Vector3 = object_ref.global_transform.origin
	var player_hand_position: Vector3 = player_hand.global_transform.origin
	var _object_distance: Vector3 = player_hand_position - object_current_position
	
	var rigid_body_3d: RigidBody3D = object_ref as RigidBody3D
	if rigid_body_3d:
		var throw_direction: Vector3 = -player_hand.global_transform.basis.z.normalized()
		var throw_strength: float = 20.0/rigid_body_3d.mass
		rigid_body_3d.set_linear_velocity(throw_direction*throw_strength)
	
	can_interact = false
	await get_tree().create_timer(1.0).timeout
	can_interact = true

func collect_item() -> void:
	emit_signal("ItemCollected", get_parent())
	get_parent().queue_free()
