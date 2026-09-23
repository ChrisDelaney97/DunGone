extends CharacterBody3D
class_name Player

@onready var standing_collision: CollisionShape3D = %StandingCollision
@onready var crouching_collision: CollisionShape3D = %CrouchingCollision
@onready var head: Node3D = %Head
@onready var eyes: Node3D = %Eyes
@onready var camera: Camera3D = %Camera
@onready var stand_up_check: RayCast3D = %StandUpCheck
@onready var audio: Node3D = %AudioManager

@onready var health_bar: ProgressBar = $HUD.get_node("VBoxContainer/HealthBar")
@onready var stamina_bar: ProgressBar = $HUD.get_node("VBoxContainer/StaminaBar")
@onready var mana_bar: ProgressBar = $HUD.get_node("VBoxContainer/ManaBar")
@onready var cast_spawn: Node3D = $CastSpawn

var lerp_speed: float = 10.0

# Movement Variables
const WALK_SPEED: float = 4.5
const SPRINT_SPEED: float = 7.0
const CROUCH_SPEED: float = 1.0
const JUMP_VELOCITY: float = 4.0
var current_speed: float = 3.0
var moving: bool = false
var input_dir: Vector2 = Vector2.ZERO
var direction: Vector3 = Vector3.ZERO
const CROUCHING_DEPTH: float = -0.9
var is_in_air: bool

# Camera Variables
var head_height: float = 1.8
var base_fov = 90.0
var input_rotation: Vector3
var mouse_input: Vector2
var joypad_input: Vector2
var mouse_sensitivity: float = 0.2
var joypad_sensitivity: float = 0.05

# Headbob Variables
const HEAD_BOBBING_SPRINTING_SPEED: float = 22.0
const HEAD_BOBBING_WALKING_SPEED: float = 14.0
const HEAD_BOBBING_CROUCHING_SPEED: float = 10.0
const HEAD_BOBBING_SPRINTING_INTENSITY: float = 0.2
const HEAD_BOBBING_WALKING_INTENSITY: float = 0.1
const HEAD_BOBBING_CROUCHING_INTENSITY: float = 0.05
var head_bobbing_vector : Vector2 = Vector2.ZERO
var head_bobbing_index: float = 0.0
var head_bobbing_current_intensity: float = 0.0
var last_bob_position_x: float = 0.0
var last_bob_direction: int = 0

# Stats Variables
var health : float = 100
var stamina : float = 100
var mana : float = 100
var stamina_recharging : bool = false

# State Machine
var player_state: PlayerState = PlayerState.IDLE_STAND
enum PlayerState {
	IDLE_STAND,
	IDLE_CROUCH,
	CROUCHING,
	WALKING,
	SPRINTING, 
	AIR
}

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _process(_delta: float) -> void:
	health_bar.value = health
	stamina_bar.value = stamina
	mana_bar.value = mana
	
	if stamina_recharging and stamina < 100.0: stamina += 0.5

func _physics_process(delta: float) -> void:
	
	update_player_state()
	update_camera(delta)
	
	if not is_on_floor():
		is_in_air = true
		if velocity.y >= 0: # when jumping
			velocity += get_gravity() * delta
		else: # when falling
			velocity += get_gravity() * delta * 2.0
	else:
		if is_in_air == true:
			is_in_air = false
			audio.play_land()
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			audio.play_jump()
	
	# Get the input direction and handle the movement/deceleration.
	input_dir = Input.get_vector("left", "right", "forward", "back")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	move_and_slide()

func update_player_state() -> void:
	moving = (input_dir != Vector2.ZERO)
	if not is_on_floor():
		player_state = PlayerState.AIR
	else:
		if Input.is_action_pressed("crouch"):
			if not moving:
				player_state = PlayerState.IDLE_CROUCH
			else:
				player_state = PlayerState.CROUCHING
		elif !stand_up_check.is_colliding():
			if not moving:
				player_state = PlayerState.IDLE_STAND
			elif Input.is_action_pressed("sprint"):
				player_state = PlayerState.SPRINTING
			else:
				player_state = PlayerState.WALKING
	
	update_player_col_shape(player_state)
	update_player_speed(player_state)

func update_player_col_shape(_player_state:PlayerState) -> void:
	if _player_state == PlayerState.CROUCHING or _player_state == PlayerState.IDLE_CROUCH:
		standing_collision.disabled = true
		crouching_collision.disabled = false
	else:
		standing_collision.disabled = false
		crouching_collision.disabled = true

func update_player_speed(_player_state:PlayerState) -> void:
	if _player_state == PlayerState.CROUCHING or _player_state == PlayerState.IDLE_CROUCH:
		current_speed = CROUCH_SPEED
	if _player_state == PlayerState.WALKING:
		current_speed = WALK_SPEED
	elif _player_state == PlayerState.SPRINTING:
		current_speed = SPRINT_SPEED

func update_camera(delta: float) -> void:
	if player_state == PlayerState.AIR:
		pass
	if player_state == PlayerState.CROUCHING or player_state == PlayerState.IDLE_CROUCH:
		head.position.y = lerp(head.position.y, head_height + CROUCHING_DEPTH, delta * lerp_speed)
		camera.fov = lerp(camera.fov, base_fov * 0.95, delta * lerp_speed)
		head_bobbing_current_intensity = HEAD_BOBBING_CROUCHING_INTENSITY
		head_bobbing_index += HEAD_BOBBING_CROUCHING_SPEED * delta
	if player_state == PlayerState.IDLE_STAND:
		head.position.y = lerp(head.position.y, head_height, delta * lerp_speed)
		camera.fov = lerp(camera.fov, base_fov, delta * lerp_speed)
		head_bobbing_current_intensity = HEAD_BOBBING_WALKING_INTENSITY
		head_bobbing_index += HEAD_BOBBING_WALKING_SPEED * delta
	if player_state == PlayerState.WALKING:
		head.position.y = lerp(head.position.y, head_height, delta * lerp_speed)
		camera.fov = lerp(camera.fov, base_fov, delta * lerp_speed)
		head_bobbing_current_intensity = HEAD_BOBBING_WALKING_INTENSITY
		head_bobbing_index += HEAD_BOBBING_WALKING_SPEED * delta
	elif player_state == PlayerState.SPRINTING:
		head.position.y = lerp(head.position.y, head_height, delta * lerp_speed)
		camera.fov = lerp(camera.fov, base_fov * 1.05, delta * lerp_speed)
		head_bobbing_current_intensity = HEAD_BOBBING_SPRINTING_INTENSITY
		head_bobbing_index += HEAD_BOBBING_SPRINTING_SPEED * delta
	
	head_bobbing_vector.y = sin(head_bobbing_index)
	head_bobbing_vector.x = sin(head_bobbing_index/2.0)
	if moving:
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y * (head_bobbing_current_intensity/2.0), delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x * (head_bobbing_current_intensity), delta * lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta * lerp_speed)
	
	footsteps()

func spend_stamina(amount:int):
	stamina_recharging = false
	stamina -= amount
	$StaminaTimer.start()

func spend_mana(amount:int):
	mana -= amount

func _on_stamina_timer_timeout() -> void:
	stamina_recharging = true

func hit(amount:int):
	health -= amount
	health_bar.value = health
	if health <= 0: death()

func death():
	queue_free()

func footsteps() -> void:
	if moving and is_on_floor():
		var bob_position_x = head_bobbing_vector.x
		var bob_direction = sign(bob_position_x - last_bob_position_x)
		
		if bob_direction != 0 and bob_direction != last_bob_direction and last_bob_direction != 0:
			audio.play_footstep()
		
		last_bob_direction = bob_direction
		last_bob_position_x = bob_position_x
	else:
		last_bob_direction = 0
		last_bob_position_x = head_bobbing_vector.x
