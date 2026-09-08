extends Node

var player_damage_modifier : int = 1

var firestaff_buff_timer := Timer.new()
var firestaff_damage_modifier : int = 1

func _process(_delta: float) -> void:
	pass
	#calculate_buff_modifier()

func calculate_buff_modifier():
	player_damage_modifier = firestaff_damage_modifier

func firestaff_buff():
	firestaff_damage_modifier = 2
	calculate_buff_modifier()
	add_child(firestaff_buff_timer)
	firestaff_buff_timer.wait_time = 10.0
	firestaff_buff_timer.one_shot = true
	firestaff_buff_timer.start()
	firestaff_buff_timer.timeout.connect(_on_firestaff_timer_timeout)

func _on_firestaff_timer_timeout():
	firestaff_damage_modifier = 1
	calculate_buff_modifier()
