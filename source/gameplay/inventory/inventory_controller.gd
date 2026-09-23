extends Control
class_name InventoryController

@onready var inventory_grid: GridContainer = %GridContainer

var item_slot_count: int = 20
var inventory_slot_prefab: PackedScene = load("uid://do63ydtostv3o")
var inventory_slots: Array[InventorySlot] = []
var inventory_full: bool = false

func _ready() -> void:
	for i in item_slot_count:
		var slot = inventory_slot_prefab.instantiate() as InventorySlot
		inventory_grid.add_child(slot)
		
