extends CharacterBody3D
class_name Player

@onready var arms: Node3D = $arms_rig
@onready var arms_anchor: Marker3D = $ArmsAnchor
@onready var camera_controller_anchor: Marker3D = $CameraControllerAnchor

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"): arms.anim_attack()
	if event.is_action_pressed("grab"): arms.anim_grab()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if $FootstepTimer.is_stopped():
			$FootstepAudio.play_sound()
			$FootstepTimer.start()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		$FootstepTimer.stop()
	
	move_and_slide()
