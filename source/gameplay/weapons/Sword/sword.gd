extends Weapon
class_name Sword

func primary_action(player: Player, anim: AnimationTree, cast_spawn: Node3D):
	if player.stamina >= primary_action_stamina_cost:
		anim["parameters/primary/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func secondary_action(player: Player, anim: AnimationTree, cast_spawn: Node3D):
	if player.stamina >= secondary_action_stamina_cost:
		anim["parameters/secondary/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
