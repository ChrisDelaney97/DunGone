class_name CameraController
extends Node3D

@onready var inventory_controller: Node = %InventoryController/CanvasLayer/InventoryUI						
@onready var head_bob: Node3D = %HeadBob
@onready var player_controller: Player = $".."

var input_rotation: Vector3
var mouse_input: Vector2
var joypad_input: Vector2
var mouse_sensitivity: float = 0.0013
var joypad_sensitivity: float = 0.05

var use_interpolation: bool = false
var circle_strafe: bool = true

const head_bob_speed : int = 14.0
const head_bob_intensity : int = 1.0
var head_bob_vector : Vector2 = Vector2.ZERO
var head_bob_index : float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	
	if Input.is_action_pressed("inventory"):
		inventory_controller.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		if event is InputEventMouseMotion:
			mouse_input.x += -event.screen_relative.x * mouse_sensitivity
			mouse_input.y += -event.screen_relative.y * mouse_sensitivity
	
	if Input.is_action_just_released("inventory"):
		inventory_controller.visible = false			
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	joypad_input = Input.get_vector("cam_right", "cam_left", "cam_down", "cam_up") * joypad_sensitivity
	
	if mouse_input:
		input_rotation.x = clampf(input_rotation.x + mouse_input.y, deg_to_rad(-90), deg_to_rad(85))
		input_rotation.y += mouse_input.x
	elif joypad_input:
		input_rotation.x = clampf(input_rotation.x + joypad_input.y, deg_to_rad(-90), deg_to_rad(85))
		input_rotation.y += joypad_input.x
	
	# rotate camera controller (up/down)
	player_controller.camera_controller_anchor.transform.basis = Basis.from_euler(Vector3(input_rotation.x, 0.0, 0.0))
	
	# rotate player (left/right)
	player_controller.global_transform.basis = Basis.from_euler(Vector3(0.0, input_rotation.y, 0.0))
	
	global_transform = player_controller.camera_controller_anchor.get_global_transform_interpolated()
	
	#head_bob_index += head_bob_speed * delta
	#head_bob_vector.y = sin(head_bob_index)
	#head_bob_vector.x = (sin(head_bob_index/2.0)+0.5)
	#head_bob.position.y = lerp(head_bob.position.y, head_bob_vector.y * (head_bob_intensity / 2.0), delta)
	#head_bob.position.x = lerp(head_bob.position.x, head_bob_vector.x * (head_bob_intensity), delta)
	
	mouse_input = Vector2.ZERO
