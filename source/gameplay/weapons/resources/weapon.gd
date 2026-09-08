extends Resource
class_name Weapon

@export var name: String
@export var primary_action_damage: int
@export var primary_action_stamina_cost: int
@export var primary_action_mana_cost: int
@export var primary_action_cooldown: float
@export var primary_action_projectile_spawn: Vector3
@export var secondary_action_damage: int
@export var secondary_action_stamina_cost: int
@export var secondary_action_mana_cost: int
@export var secondary_action_cooldown: float
@export var secondary_action_projectile_spawn: Vector3
@export var model: PackedScene
@export var position: Vector3

func primary_action(player: Player, anim: AnimationTree, cast_spawn: Node3D):
	if player.stamina >= primary_action_stamina_cost and player.mana >= primary_action_mana_cost:
		player.spend_stamina(primary_action_stamina_cost)
		player.spend_mana(primary_action_mana_cost)
		anim["parameters/primary/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	
func secondary_action(player: Player, anim: AnimationTree, cast_spawn: Node3D):
	if player.stamina >= secondary_action_stamina_cost and player.mana >= secondary_action_mana_cost:
		player.spend_stamina(secondary_action_stamina_cost)
		player.spend_mana(secondary_action_mana_cost)
		anim["parameters/secondary/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
