extends Node3D

var stats: Weapon
var enemies_hit : Array
var damage : int

func _on_sword_collision_body_entered(body: Node3D) -> void:
	if body is Enemy and !enemies_hit.has(body):
		enemies_hit.append(body)
		body.hit(damage)

func clear_enemies_hit():
	enemies_hit.clear()

func set_damage_primary():
	damage = stats.primary_action_damage

func set_damage_secondary():
	damage = stats.secondary_action_damage
