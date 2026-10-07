extends Control
class_name InventoryController

@onready var player: Player = $"../../../.."
@onready var hand: Marker3D = $"../../../../Head/Eyes/Camera/Hand"
@onready var camera: Camera3D = $"../../../../Head/Eyes/Camera"
@onready var context_menu: PopupMenu = PopupMenu.new()
@onready var inventory_grid: GridContainer = %ItemGrid
@onready var weapon_controller: WeaponController = $"../../../WeaponController"
@onready var equip_slot_1: InventorySlot = %EquipSlot1
@onready var equip_slot_2: InventorySlot = %EquipSlot2
@onready var equip_highlight_1: PanelContainer = %EquipHighlight1
@onready var equip_highlight_2: PanelContainer = %EquipHighlight2
@onready var text_prompt: Label = %TextPrompt
@onready var text_prompt_timer: Timer = %TextPromptTimer

var item_slot_count: int = 20
var equip_slot_count: int = 2
var inventory_slot_prefab: PackedScene = load("uid://do63ydtostv3o")
var inventory_slots: Array[InventorySlot] = []
var equip_slots: Array[InventorySlot] = []
var inventory_full: bool = false

func _process(_delta: float) -> void:
	if weapon_controller.primary_slot_selected:
		equip_highlight_1.modulate.a = 255
		equip_highlight_2.modulate.a = 0
	if !weapon_controller.primary_slot_selected:
		equip_highlight_1.modulate.a = 0
		equip_highlight_2.modulate.a = 255

func _ready() -> void:
	for i in item_slot_count:
		var slot = inventory_slot_prefab.instantiate() as InventorySlot
		inventory_grid.add_child(slot)
		slot.inventory_slot_id = i
		slot.OnItemSwapped.connect(on_item_swapped_on_slot)
		slot.OnItemDoubleClicked.connect(on_item_double_clicked)
		slot.OnItemRightClicked.connect(on_item_right_clicked)
		inventory_slots.append(slot)
	
	equip_slot_1.equip_slot = true
	equip_slot_1.OnItemSwapped.connect(on_item_swapped_on_slot)
	equip_slot_1.OnItemDoubleClicked.connect(on_item_double_clicked)
	equip_slot_1.OnItemRightClicked.connect(on_item_right_clicked)
	equip_slot_1.inventory_slot_id = 20
	inventory_slots.append(equip_slot_1)
	
	equip_slot_2.equip_slot = true
	equip_slot_2.OnItemSwapped.connect(on_item_swapped_on_slot)
	equip_slot_2.OnItemDoubleClicked.connect(on_item_double_clicked)
	equip_slot_2.OnItemRightClicked.connect(on_item_right_clicked)
	equip_slot_2.inventory_slot_id = 21
	inventory_slots.append(equip_slot_2)
	
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

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	var slot: InventorySlot = inventory_slots[data]
	if slot.slot_data == null: return false
	else: return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	drop_collectable(data)
	inventory_full = not has_free_slot()

func on_item_swapped_on_slot(from_slot_id: int, to_slot_id: int) -> void:
	var from_slot_item: ItemData = inventory_slots[from_slot_id].slot_data
	var to_slot_item: ItemData = inventory_slots[to_slot_id].slot_data
	
	if inventory_slots[to_slot_id].equip_slot and !inventory_slots[from_slot_id].equip_slot:
		if get_item_action_type(from_slot_item) == ActionData.ActionType.EQUIPPABLE:
			match to_slot_id:
				20:
					equip(from_slot_id, 1, from_slot_item)
					inventory_slots[to_slot_id].fill_slot(from_slot_item)
					inventory_slots[from_slot_id].fill_slot(to_slot_item)
				21:
					equip(from_slot_id, 2, from_slot_item)
					inventory_slots[to_slot_id].fill_slot(from_slot_item)
					inventory_slots[from_slot_id].fill_slot(to_slot_item)
		else:
			show_text_prompt("NOT EQUIPPABLE")
			return
	
	elif inventory_slots[from_slot_id].equip_slot and !inventory_slots[to_slot_id].equip_slot:
		if not (get_item_action_type(to_slot_item) == ActionData.ActionType.CONSUMABLE or get_item_action_type(to_slot_item) == ActionData.ActionType.INSPECTABLE):
			match from_slot_id:
				20:
					unequip(from_slot_id, 1, from_slot_item)
					inventory_slots[to_slot_id].fill_slot(from_slot_item)
					inventory_slots[from_slot_id].fill_slot(to_slot_item)
				21:
					unequip(from_slot_id, 2, from_slot_item)
					inventory_slots[to_slot_id].fill_slot(from_slot_item)
					inventory_slots[from_slot_id].fill_slot(to_slot_item)
		else:
			show_text_prompt("NOT EQUIPPABLE")
			return
		
	elif inventory_slots[to_slot_id].equip_slot and inventory_slots[from_slot_id].equip_slot:
		match from_slot_id:
			20:
				unequip(from_slot_id, 1, from_slot_item)
				equip(from_slot_id, 2, from_slot_item)
				inventory_slots[to_slot_id].fill_slot(from_slot_item)
				inventory_slots[from_slot_id].fill_slot(to_slot_item)
			21:
				unequip(from_slot_id, 2, from_slot_item)
				equip(from_slot_id, 1, from_slot_item)
				inventory_slots[to_slot_id].fill_slot(from_slot_item)
				inventory_slots[from_slot_id].fill_slot(to_slot_item)
	
	else:
		inventory_slots[to_slot_id].fill_slot(from_slot_item)
		inventory_slots[from_slot_id].fill_slot(to_slot_item)

func on_item_double_clicked(slot_id: int) -> void:
	var slot: InventorySlot = inventory_slots[slot_id]
	if slot.slot_data == null: return
	match get_item_action_type(slot.slot_data):
		ActionData.ActionType.CONSUMABLE:
			use_collectable(slot_id)
		ActionData.ActionType.EQUIPPABLE:
			if !slot.equip_slot:
				on_item_swapped_on_slot(slot_id, 20)
			if slot == equip_slot_1:
				pickup_item(slot.slot_data)
				equip_slot_1.fill_slot(null)
				unequip(slot_id, 1)
			if slot == equip_slot_2:
				pickup_item(slot.slot_data)
				equip_slot_2.fill_slot(null)
				unequip(slot_id, 2)
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
			if !slot.equip_slot:
				context_menu.add_item("Equip Primary", 0)
				context_menu.add_item("Equip Secondary", 1)
				context_menu.add_item("Drop", 2)
			if slot == equip_slot_1:
				context_menu.add_item("Unequip", 0)
				context_menu.add_item("Equip Secondary", 1)
				context_menu.add_item("Drop", 2)
			if slot == equip_slot_2:
				context_menu.add_item("Unequip", 0)
				context_menu.add_item("Equip Primary", 1)
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
			if !slot.equip_slot:
				match id:
					0: on_item_swapped_on_slot(slot_id, 20)
					1: on_item_swapped_on_slot(slot_id, 21)
					2: drop_collectable(slot_id)
			if slot == equip_slot_1:
				match id:
					0: 
						pickup_item(slot.slot_data)
						equip_slot_1.fill_slot(null)
						unequip(slot_id, 1, slot.slot_data)
					1:
						on_item_swapped_on_slot(slot_id, 21)
					2:
						drop_collectable(slot_id)
						#unequip(slot_id, 1, slot.slot_data)
			if slot == equip_slot_2:
				match id:
					0: 
						pickup_item(slot.slot_data)
						equip_slot_2.fill_slot(null)
						unequip(slot_id, 2, slot.slot_data)
					1:
						on_item_swapped_on_slot(slot_id, 20)
					2:
						drop_collectable(slot_id)
						#unequip(slot_id, 2, slot.slot_data)
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
	
	if slot == equip_slot_1:
		unequip(slot_id, 1, slot.slot_data)
	elif slot == equip_slot_2:
		unequip(slot_id, 2, slot.slot_data)
	else: 
		slot.fill_slot(null)
		inventory_full = not has_free_slot()

func equip(slot_id: int, weapon_slot: int = 1, weapon_data: ItemData = null) -> void:
	var slot: InventorySlot = inventory_slots[slot_id]
	if weapon_data:
		match weapon_data.action_data.equip_type:
			0: # weapon
				if weapon_data.action_data.weapon_data:
					var weapon: Weapon = weapon_data.action_data.weapon_data
					match weapon_slot:
						1:
							weapon_controller.equip_weapon(weapon, 1)
							slot.fill_slot(null)
							inventory_full = not has_free_slot()
						2:
							weapon_controller.equip_weapon(weapon, 2)
							slot.fill_slot(null)
							inventory_full = not has_free_slot()
							
			1: # armour
				pass
	elif slot.slot_data == null: return

func unequip(slot_id: int, weapon_slot: int = 1, weapon_data: ItemData = null) -> void:
	var slot: InventorySlot = inventory_slots[slot_id]
	if weapon_data:
		match weapon_data.action_data.equip_type:
			0: # Weapon
				match weapon_slot:
					1:
						weapon_controller.equip_weapon(null, 1)
						slot.fill_slot(null)
						inventory_full = not has_free_slot()
					2:
						weapon_controller.equip_weapon(null, 2)
						slot.fill_slot(null)
						inventory_full = not has_free_slot()
			1: # Armour
				pass
	elif slot.slot_data == null: return

func show_text_prompt(text: String) -> void:
	text_prompt.text = text
	text_prompt.visible = true
	text_prompt_timer.start()

func _on_text_prompt_timer_timeout() -> void:
	text_prompt.text = ""
	text_prompt.visible = false
