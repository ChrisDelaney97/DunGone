extends CharacterBody3D

@onready var lifetime_timer: Timer = $LifetimeTimer

const SPEED: float = 500.0
var damage: int

func _ready() -> void:
	lifetime_timer.start()

func _physics_process(delta: float) -> void:
	velocity = transform.basis * Vector3(0,0,SPEED) * delta
	move_and_slide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Enemy:
		body.hit(damage)
		queue_free()
	if body.is_in_group("ground"):
		queue_free()

func _on_lifetime_timer_timeout() -> void:
	queue_free()
