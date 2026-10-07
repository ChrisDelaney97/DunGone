extends ActionData
class_name EquippableAction

enum EquipType {
	WEAPON,
	ARMOUR
}

@export var equip_type: EquipType
@export var weapon_data: Weapon
@export var one_time_use: bool = true
@export var success_text:String = "Action Success"

func _init() -> void:
	action_type = ActionType.EQUIPPABLE
