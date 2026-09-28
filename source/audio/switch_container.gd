@icon("uid://t3tt8c3qqs6c")
extends Node3D
class_name SwitchContainer

@export var default_condition: String
@export var conditions: Array[String] = []
@export var sounds: Array[AudioStreamPlayer3D] = []
var current_sound: AudioStreamPlayer3D
var current_condition: String

func _ready() -> void:
	current_condition = default_condition
	if sounds.is_empty():
		return
	else:
		for sound in sounds:
			if sound.condition == current_condition:
				current_sound = sound

func play_switch_sound() -> void:
	if current_sound:
		if current_sound is RandomContainer:
			current_sound.play_random()
		else:
			current_sound.play()

func change_condition(condition: String):
	if !conditions.has(condition):
		current_condition = default_condition
		assert(false, "Condition " + str(condition) + " not in list")
	else:
		current_condition = condition
		# print("Condition changed to " + str(condition))
		for sound in sounds:
			if sound.condition == current_condition:
				current_sound = sound

#func _input(event: InputEvent) -> void:
	#if Input.is_action_just_pressed("test"):
		#change_condition("Poop")
