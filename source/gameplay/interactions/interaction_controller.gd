extends Node
class_name InteractionController

@onready var interaction_controller: InteractionController = %InteractionController
@onready var interaction_raycast: RayCast3D = %InteractionRaycast
@onready var camera: Camera3D = %Camera

var current_object: Object 
var last_potential_object: Object
var interaction_component: Node

func _process(delta: float) -> void:
	return
