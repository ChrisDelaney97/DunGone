extends CharacterBody3D

const SPEED: float = 500.0
var damage: int

func _physics_process(delta: float) -> void:
	velocity = transform.basis * Vector3(0,0,SPEED) * delta
	move_and_slide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Enemy:
		body.hit(damage)
		queue_free()
