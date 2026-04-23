extends Node
class_name TurnControl

@onready var turn_panel: Panel = $TurnPanel
@onready var turn_label: Label = $TurnPanel/TurnLabel

var current_turn: int = 0
var turn_actions: int
var turn_order: Array[int]

func turn_order_getter(characters: Array[CharacterClass]) -> void:
	var sorted_characters: Array[CharacterClass]
	
	sorted_characters.append_array(characters)
	
	sorted_characters.sort_custom(turn_sorting)
	
	for chr in sorted_characters:
		turn_order.append(chr.level_index)
	

func turn_sorting(character_a: CharacterClass, character_b: CharacterClass) -> bool:
	#This custom function basically makes the faster character go first
	#But, in case of a tie, it's a random one
	var agility_a: int = character_a.current_agility
	var agility_b: int = character_b.current_agility
	
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
	

func turn_start(characters: Array[CharacterClass]) -> void:
	current_turn += 1
	update_turn_ui()
	turn_order_getter(characters)
	turn_actions = turn_order.size()
	print("Starting Turn {0}!".format([current_turn]))
	print("Turn Order:")
	for i in range(turn_order.size()):
		print("#{0}: {1}".format([i + 1, characters[turn_order[i]].character_name]))
	

func turn_end() -> void:
	turn_order.clear()
	turn_actions = 0
	print("End of Turn {0}.".format([current_turn]))

func update_turn_ui() -> void:
	turn_label.text = "Turn {0}".format([current_turn])
	
