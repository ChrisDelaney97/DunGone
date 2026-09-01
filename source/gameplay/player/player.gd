extends CharacterBody3D
class_name Player

@onready var camera_controller_anchor: Marker3D = $CameraControllerAnchor
@onready var health_bar: ProgressBar = $HUD.get_node("VBoxContainer/HealthBar")
@onready var stamina_bar: ProgressBar = $HUD.get_node("VBoxContainer/StaminaBar")
@onready var mana_bar: ProgressBar = $HUD.get_node("VBoxContainer/ManaBar")
@onready var cast_spawn: Node3D = $CastSpawn

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var health : float = 100
var stamina : float = 100
var mana : float = 100

var stamina_recharging : bool = false

func _process(_delta: float) -> void:
	health_bar.value = health
	stamina_bar.value = stamina
	mana_bar.value = mana
	
	if stamina_recharging and stamina < 100.0: stamina += 0.5

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if $FootstepTimer.is_stopped():
			$FootstepAudio.play_randomised_sound()
			$FootstepTimer.start()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		$FootstepTimer.stop()
	
	move_and_slide()

func spend_stamina(amount:int):
	stamina_recharging = false
	stamina -= amount
	$StaminaTimer.start()

func spend_mana(amount:int):
	mana -= amount

func _on_stamina_timer_timeout() -> void:
	stamina_recharging = true
