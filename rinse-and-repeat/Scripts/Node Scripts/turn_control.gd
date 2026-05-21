extends Control
class_name TurnControl
#This is the Script for the TurnControl Scene

@onready var turn_panel: Panel = $TurnPanel
@onready var turn_label: Label = $TurnPanel/TurnLabel

#These are the variables that TurnControl holds and helps the board with the turn logic
var current_turn: int = 0
var turn_actions: int
var turn_order: Array[int]

#This function sorts the Characters by their Agility and stores their index in the turn_order Array
func turn_order_getter(characters: Array[CharacterClass]) -> void:
	var sorted_characters: Array[CharacterClass]
	
	sorted_characters.append_array(characters)
	
	sorted_characters.sort_custom(turn_sorting)
	
	for chr in sorted_characters:
		turn_order.append(chr.level_index)
	

#This custom function basically makes the faster character go first
#But, in case of a tie, it's a random one, because I like the 50/50
func turn_sorting(character_a: CharacterClass, character_b: CharacterClass) -> bool:
	var agility_a: int = character_a.current_agility
	var agility_b: int = character_b.current_agility
	
	if agility_a > agility_b:
		return true
	elif agility_a == agility_b:
		var coin_flip: int = randi_range(0, 1)
		if coin_flip == 0:
			return true
		else:
			return false
	else:
		return false
	

#This function updates the turn of the game and makes everything ready for the next turn
func turn_start(characters: Array[CharacterClass]) -> void:
	current_turn += 1
	update_turn_ui()
	turn_order_getter(characters)
	turn_actions = turn_order.size()
	print("Starting Turn {0}!".format([current_turn]))
	print("Turn Order:")
	for i in range(turn_order.size()):
		print("#{0}: {1}".format([i + 1, characters[turn_order[i]].character_name]))
	

#This function resets the turn_order and turn_actions so that turn_start can calculate them without issue
func turn_end() -> void:
	turn_order.clear()
	turn_actions = 0
	print("End of Turn {0}.".format([current_turn]))
	

#This function updates the turn on screen
func update_turn_ui() -> void:
	turn_label.text = "Turn {0}".format([current_turn])
	
