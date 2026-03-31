extends Node

var max_health: int = 10
var pace: int = 2
var agility: int = 5
var move_directions: Array[String] = ["UP", "DOWN", "LEFT", "RIGHT"]
var actions: Array[String] = ["ATTACK", "HEAL"]

func player_action(action: String) -> void:
	match action:
		"ATTACK":
			attack()
			
		"HEAL":
			heal()
			
		

func attack() -> void:
	print("Player attacked!")
	

func heal() -> void:
	print("Player healed!")
	
