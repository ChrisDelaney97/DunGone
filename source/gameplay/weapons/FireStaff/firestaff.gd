extends Weapon
class_name FireStaff

const FIREBALL = preload("uid://bdw1ppxlns7ol")
var fireball

func primary_action(player: Player, anim: AnimationTree, cast_spawn: Node3D):
	if player.mana >= primary_action_mana_cost:
		anim["parameters/primary/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		player.spend_mana(primary_action_mana_cost)
		fireball = FIREBALL.instantiate()
		fireball.damage = primary_action_damage
		fireball.position = cast_spawn.global_position
		fireball.transform.basis = cast_spawn.global_transform.basis
		player.add_child(fireball)

func secondary_action(player: Player, anim: AnimationTree, cast_spawn: Node3D):
	if player.mana >= secondary_action_mana_cost:
		anim["parameters/secondary/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		player.spend_mana(secondary_action_mana_cost)
