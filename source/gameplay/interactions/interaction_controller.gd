extends Node
class_name InteractionController

@onready var interaction_controller: InteractionController = %InteractionController
@onready var interaction_raycast: RayCast3D = %InteractionRaycast
@onready var camera: Camera3D = %Camera
@onready var hand: Marker3D = %Hand
@onready var default_reticle: ColorRect = $"../../GUI/Reticle/Control/DefaultReticle"
@onready var highlight_reticle: Panel = $"../../GUI/Reticle/Control/HighlightReticle"
@onready var interact_reticle: Panel = $"../../GUI/Reticle/Control/InteractReticle"
@onready var inventory_controller: Node = %InventoryController/CanvasLayer/InventoryUI

var current_object: Object 
var last_potential_object: Object
var interaction_component: Node

signal InventOnItemCollected (item)

func _ready() -> void:
	InventOnItemCollected.connect(inventory_controller.pickup_item)
	#default_reticle.position.x = get_viewport().size.x/2
	#default_reticle.position.y = get_viewport().size.y/2

func _process(_delta: float) -> void:
	if !inventory_controller.visible:
		default_reticle.visible = true
		if interaction_component and interaction_component.is_interacting:
			interact_reticle.visible = true
		else:
			interact_reticle.visible = false
		
		if current_object:
			if Input.is_action_just_pressed("interact_secondary"):
				if interaction_component:
					interaction_component.secondary_interact()
					current_object = null
					unfocus()
			if Input.is_action_pressed("hold"):
				if interaction_component and interaction_component.interaction_type == 0:
					interaction_component.interact()
			elif Input.is_action_pressed("pickup") and interaction_component.interaction_type == interaction_component.InteractionType.ITEM:
				interaction_component.interact()
			else:
				if interaction_component:
					interaction_component.post_interact()
					current_object = null
					unfocus()
		else:
			var potential_object: Object = interaction_raycast.get_collider()
			if potential_object and potential_object is Node:
				interaction_component = potential_object.get_node_or_null("InteractionComponent")
				if interaction_component:
					if interaction_component.can_interact == false:
						return
					last_potential_object = current_object
					focus()
					if Input.is_action_just_pressed("hold"):
						current_object = potential_object
						interaction_component.pre_interact(hand)
					if Input.is_action_just_pressed("pickup") and interaction_component.interaction_type == interaction_component.InteractionType.ITEM:
						current_object = potential_object
						interaction_component.pre_interact(hand)
						if interaction_component.interaction_type == interaction_component.InteractionType.ITEM:
							interaction_component.connect("ItemCollected", Callable(self, "on_item_collected"))
			else:
				unfocus()
	else:
		highlight_reticle.visible = false
		default_reticle.visible = false
		interact_reticle.visible = false
		current_object = null

func focus() -> void:
	highlight_reticle.visible = true

func unfocus() -> void:
	highlight_reticle.visible = false

func on_item_collected(item: Node) -> void:
	item.visible = false
	var data: ItemData = item.get_node("InteractionComponent").item_data
	add_item_to_inventory(data)
	# WAIT FOR AUDIO TO FINISH PLAYING IF ATTACHED
	item.queue_free()

func add_item_to_inventory(item_data: ItemData) -> void:
	if item_data:
		InventOnItemCollected.emit(item_data)
		return
	print("ItemData not found")
