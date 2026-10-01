extends Control
class_name InventoryController

@onready var player: Player = $"../../../.."
@onready var hand: Marker3D = $"../../../../Head/Eyes/Camera/Hand"
@onready var camera: Camera3D = $"../../../../Head/Eyes/Camera"
@onready var context_menu: PopupMenu = PopupMenu.new()
@onready var inventory_grid: GridContainer = %GridContainer

var item_slot_count: int = 20
var inventory_slot_prefab: PackedScene = load("uid://do63ydtostv3o")
var inventory_slots: Array[InventorySlot] = []
var inventory_full: bool = false

func _ready() -> void:
	for i in item_slot_count:
		var slot = inventory_slot_prefab.instantiate() as InventorySlot
		inventory_grid.add_child(slot)
		slot.inventory_slot_id = i
		slot.OnItemSwapped.connect(on_item_swapped_on_slot)
		slot.OnItemDoubleClicked.connect(on_item_double_clicked)
		slot.OnItemRightClicked.connect(on_item_right_clicked)
		inventory_slots.append(slot)
	
	add_child(context_menu)
	context_menu.connect("id_pressed", Callable(self, "on_context_menu_selected"))

func has_free_slot() -> bool:
	for slot in inventory_slots:
		if slot.slot_data == null:
			return true
	return false

func pickup_item(item_data: ItemData) -> void:
	for slot in inventory_slots:
		if not slot.slot_filled:
			slot.fill_slot(item_data)
			inventory_full = not has_free_slot()
			return
	inventory_full = true

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	var slot: InventorySlot = inventory_slots[data]
	if slot.slot_data == null: return false
	else: return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	drop_collectable(data)
	inventory_full = not has_free_slot()

func on_item_swapped_on_slot(from_slot_id: int, to_slot_id: int) -> void:
	var to_slot_item: ItemData = inventory_slots[to_slot_id].slot_data
	var from_slot_item: ItemData = inventory_slots[from_slot_id].slot_data
	inventory_slots[to_slot_id].fill_slot(from_slot_item)
	inventory_slots[from_slot_id].fill_slot(to_slot_item)

func on_item_double_clicked(slot_id: int) -> void:
	var slot: InventorySlot = inventory_slots[slot_id]
	if slot.slot_data == null: return
	match get_item_action_type(slot.slot_data):
		ActionData.ActionType.CONSUMABLE:
			use_collectable(slot_id)
		ActionData.ActionType.EQUIPPABLE:
			print("Equip Primary")
		ActionData.ActionType.INSPECTABLE:
			print("View Item")

func on_item_right_clicked(slot_id: int) -> void:
	var slot: InventorySlot = inventory_slots[slot_id]
	if slot.slot_data == null: return
	context_menu.clear()
	match get_item_action_type(slot.slot_data):
		ActionData.ActionType.CONSUMABLE:
			context_menu.add_item("Use", 0)
			context_menu.add_item("Drop", 1)
		ActionData.ActionType.EQUIPPABLE:
			context_menu.add_item("Equip Primary", 0)
			context_menu.add_item("Equip Secondary", 1)
			context_menu.add_item("Drop", 2)
		ActionData.ActionType.INSPECTABLE:
			context_menu.add_item("View", 0)
			context_menu.add_item("Drop", 1)
	
	context_menu.set_meta("slot_id", slot_id)
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var rect: Rect2i = Rect2i(mouse_pos.floor(), Vector2i(1,1))
	context_menu.popup(rect)

func on_context_menu_selected(id: int) -> void:
	var slot_id = context_menu.get_meta("slot_id")
	var slot: InventorySlot = inventory_slots[slot_id]
	if slot.slot_data == null: return 
	match get_item_action_type(slot.slot_data):
		ActionData.ActionType.CONSUMABLE:
			match id:
				0: use_collectable(slot_id)
				1: drop_collectable(slot_id)
		ActionData.ActionType.EQUIPPABLE:
			match id:
				0: print("Equip Primary")
				1: print("Equip Secondary")
				2: drop_collectable(slot_id)
		ActionData.ActionType.INSPECTABLE:
			match id:
				0: print("View Item")
				1: drop_collectable(slot_id)

func get_item_action_type(item_data: ItemData) -> ActionData.ActionType:
	if item_data == null or item_data.item_model_prefab == null:
		return ActionData.ActionType.INVALID
	return item_data.action_data.action_type
	
func use_collectable(slot_id: int) -> void:
	var slot: InventorySlot = inventory_slots[slot_id]
	if slot.slot_data == null: return 
	var action_data: ActionData = slot.slot_data.action_data
	match action_data.modifier_name:
		"health_potion":
			if player.add_health(action_data.modifier_value): remove_collectable(slot)
		"mana_potion":
			if player.add_mana(action_data.modifier_value): remove_collectable(slot)

func remove_collectable(slot: InventorySlot) -> void:
	inventory_full = not has_free_slot()
	slot.fill_slot(null)

func drop_collectable(slot_id: int) -> void:
	var slot: InventorySlot = inventory_slots[slot_id]
	if slot.slot_data == null: return 
	
	var instance = slot.slot_data.item_model_prefab.instantiate() as Node3D
	get_tree().current_scene.add_child(instance)
	
	var drop_distance: float = 2.0
	var forward_dir: Vector3 = -camera.global_transform.basis.z.normalized()
	var target_pos: Vector3 = camera.global_transform.origin + forward_dir * drop_distance
	var space_state = hand.get_world_3d().direct_space_state
	
	var obstacle_params = PhysicsRayQueryParameters3D.new()
	obstacle_params.from = camera.global_transform.origin
	obstacle_params.to = target_pos
	obstacle_params.exclude = [hand.get_parent()]
	
	var obstacle_hit: Dictionary = space_state.intersect_ray(obstacle_params)
	if obstacle_hit: return
	
	var ground_params = PhysicsRayQueryParameters3D.new()
	ground_params.from = target_pos + Vector3.UP * 2.0
	ground_params.to = target_pos - Vector3.UP * 5.0
	ground_params.exclude = [hand.get_parent()]
	
	var ground_hit: Dictionary = space_state.intersect_ray(ground_params)
	if !ground_hit: return
	
	var ground_pos: Vector3 = ground_hit.position
	
	var buffer_height: float = 0.5
	if instance is RigidBody3D:
		instance.global_transform.origin = ground_pos + Vector3.UP * buffer_height
		instance.freeze = false
		instance.gravity_scale = 1.0
		instance.rotation_degrees.x = randf() * 360
		instance.rotation_degrees.z= randf() * 360
	else:
		instance.global_transform.origin = ground_pos + Vector3.UP * 0.01
	
	slot.fill_slot(null)
	inventory_full = not has_free_slot()
