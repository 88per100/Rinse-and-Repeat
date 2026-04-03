extends Node

var turn_counter: int = 0

@onready var turn_label: Label = $"Turn Label"

func turn_start() -> void:
	turn_counter += 1
	update_label()
	print("Turn {0}: START!".format([turn_counter]))
	

func turn_end() -> void:
	print("Turn {0} ended.".format([turn_counter]))
	

func update_label() -> void:
	var updated_label: String = "Turn {0}".format([turn_counter])
	turn_label.text = updated_label

func turn_order_calculator(_enemy_dictionary: Dictionary) -> Array[Array]:
	#This function organizes the characters according to their 'agility'
	
	var turn_order_array: Array[Array]
	
	turn_order_array.append([-1, PlayerControl.agility])
	
	for index in _enemy_dictionary.keys():
		turn_order_array.append([index, _enemy_dictionary[index].agility])
	
	turn_order_array.sort_custom(turn_sorting_function)
	return turn_order_array
	

func turn_sorting_function(character_a: Array, character_b: Array) -> bool:
	#This custom function basically makes the faster character go first
	#But, in case of a tie, it's a random one
	var agility_a: int = character_a[1]
	var agility_b: int = character_b[1]
	
	if agility_a > agility_b:
		return true
	elif agility_a == agility_b:
		var coin_flip: int = randi_range(0,1)
		if coin_flip == 0:
			return true
		else:
			return false
	else:
		return false
	
