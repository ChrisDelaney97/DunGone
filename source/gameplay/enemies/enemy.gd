extends CharacterBody3D
class_name Enemy

@onready var health_bar: ProgressBar = $SubViewport/HealthBar

@export var health : int = 10
@export var damage: int = 10

var state: String = "idle"

var chase_target: Player
var attack_target: Player
var current_attack_target: Player
var attacking: bool = false
var dead: bool = false

const MOVE_SPEED:= 2

func _ready() -> void:
	health_bar.max_value = health
	health_bar.value = health

func _physics_process(_delta: float) -> void:
	if !dead:
		if chase_target and !current_attack_target: state = "chasing"
		elif current_attack_target: state = "attacking"
		else: state = "idle"
		
		match state:
			"idle": idle()
			"attacking": attack()
			"chasing": chasing()
		
		move_and_slide()

func chasing():
	$AnimationPlayer.play("skeleton-skeleton|run")
	var direction = position.direction_to(chase_target.global_position).normalized()
	var angle = atan2(-direction.x, -direction.z)
	rotation.y = lerp_angle(rotation.y, angle, 0.1)
	velocity = direction * MOVE_SPEED

func idle():
	velocity = Vector3.ZERO
	$AnimationPlayer.play("skeleton-skeleton|idle")

func hit(amount: int):
	health -= amount * BuffManager.player_damage_modifier
	health_bar.value = health
	if health <= 0: death()

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is Player: chase_target = body

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body is Player: chase_target = null

func _on_attack_area_body_entered(body: Node3D) -> void:
	if body is Player:
		attack_target = body
		current_attack_target = attack_target

func _on_attack_area_body_exited(body: Node3D) -> void:
	if body is Player: attack_target = null

func attack():
	velocity = Vector3.ZERO
	$AnimationPlayer.play("skeleton-skeleton|attack")

func attack_end():
	current_attack_target = attack_target
	if chase_target and !current_attack_target: state = "chasing"
	else: state = "idle"

func death():
	dead = true
	$AnimationPlayer.play_backwards("skeleton-skeleton|spawn")

func _on_hit_area_body_entered(body: Node3D) -> void:
	if body is Player: body.hit(damage)
