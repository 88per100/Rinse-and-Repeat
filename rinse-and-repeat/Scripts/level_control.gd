extends Node

var current_level: int
var enemy_number: int



func enemy_number_calculator(level: int) -> void:
	if current_level:
		enemy_number = level
	else:
		enemy_number = 0

func update_level() -> void:
	current_level += 1
	enemy_number_calculator(current_level)
