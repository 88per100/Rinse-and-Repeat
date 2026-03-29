extends Node

var turn_counter: int = 0
var player_turn_over_check: bool = false
var enemies_turn_over_check: bool = false

func turn_start() -> void:
	player_turn_over_check = false
	enemies_turn_over_check = false
	turn_counter += 1
	print("Turn {0}: START!".format([turn_counter]))
	

func turn_end() -> void:
	print("Turn {0} ended.".format([turn_counter]))
	turn_start()
