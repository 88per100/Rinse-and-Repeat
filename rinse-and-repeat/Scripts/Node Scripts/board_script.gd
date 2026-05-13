extends Node2D
class_name Board

#Tile Scene and Turn Control Scene are preloaded to be instantiated on the board's scene
@onready var tile_scene: PackedScene = preload("uid://biqedlsv4qd0v")
@onready var turn_control_scene: PackedScene = preload("uid://c7aa8xuqmjbrc")

#These variables are currently decided on an export to be easier to set and test
#They will be most likely be set in a different way
@export_subgroup("Board Dimensions")
@export var height_min: int = 3
@export var height_max: int = 8
@export_range(0.5, 1.0) var board_screen_ratio: float

#TESTING
#The enemy and player will be placed on the board in a different way
#But, for easier testing, we're doing it like this right now
@onready var player: PackedScene = preload("uid://bbqrjumu8yvow")
@onready var enemy_1: PackedScene = preload("uid://du7vixn5psi54")
@onready var enemy_2: PackedScene = preload("uid://bl8svrbyycwbd")
var character_list: Array[CharacterClass]
#----------------

#These are the real values for the board dimensions
#They are set and calculated in the function: set_board_dimensions()
var height: int
var length: int
var tile_size: float

#Variable that stores the TurnControl node that gets instantiated on to the board
var turn_control: TurnControl

#Range of time for the transition between turns and actions
#Probably will be changed or removed later
var transition_range: Array[float] = [0.3, 0.4]

#Self explanatory, but these store everything related to the positions on the board
#Logical Board: Stores each Logical Position of the board
#Positions Dictionary: Gives each Logical Position its respective Visual Position on the Screen
#Tile Dictionary: Gives each Logical Position its respective Tile Scene
var logical_board: Array[Vector2i]
var positions_dictionary: Dictionary[Vector2i, Vector2]
var tile_dictionary: Dictionary[Vector2i, Tile]

#Variable that stores the Player Character for the board to control
var player_character: CharacterClass

#Again, self explanatory, but these variables and signals make the turn logic possible
#player_to_move: Lets the board know if the player is about to move
#player_movement_over(): Lets the board know when the player's movement is over
#player_action_over(): Lets the board know when the player's action is over
#npc_movement_over(): Lets the board know when a NPC's movement is over
#npc_action_over(): Lets the board know when a NPC's action is over
#new_turn(): Lets the board know when a new turn is set to begin
var player_to_move: bool = false
signal player_movement_over()
signal player_action_over()
signal npc_movement_over()
signal npc_action_over()
signal new_turn()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_board_dimensions()
	logical_board = logical_board_creator()
	positions_dictionary = positions_dictionary_creator()
	turn_control_initializer()
	board_tile_placer()
	
	character_tester_placer()
	#After getting characters
	turn_control.turn_start(character_list)
	
	new_turn.emit()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

#This function sets the actual board dimensions
#It takes the height range set in the export variables and gets the length from a ratio
#That ratio goes from 1.5 to 16/9 to ensure the desired board format
func set_board_dimensions() -> void:
	#Firstly, the height is randomly chosen from the range
	height = randi_range(height_min, height_max)
	#Then the tile size is calculated from that height and the board to screen ratio
	tile_size = get_viewport_rect().end.y * board_screen_ratio / height
	
	#Next, it calculates lengths that fit the ratios that we defined
	var length_array: Array[int]
	for i in range(height, height * 2):
		if (i / float(height)) >= 1.5 and (i / float(height)) < (16.0 / 9.0):
			length_array.append(i)
		else:
			continue
	
	#After all of it, we chose a length at random from the ones calculated
	length = length_array[randi_range(0, length_array.size() - 1)]
	

#This function calculates and returns the logical positions of the board
func logical_board_creator() -> Array[Vector2i]:
	var result: Array[Vector2i]
	
	#Simply, we set a for loop for the height and for the length of the board
	#and we add each of the Vectors to the final array
	for i in range(height):
		for j in range(length):
			result.append(Vector2i(i, j))
	
	return result
	

#This function creates the Visual Positions for each Logical Position and returns it as a Dictionary
func positions_dictionary_creator() -> Dictionary[Vector2i, Vector2]:
	var result: Dictionary[Vector2i, Vector2]
	
	#First, it calculates the center position of the screen
	var center_position: Vector2 = Vector2(get_viewport_rect().end.x, get_viewport_rect().end.y) * 0.5
	
	#Then, it calculates the position of the top left tile
	var first_tile_position: Vector2 = center_position - Vector2(tile_size * (length - 1) * 0.5, tile_size * (height - 1) * 0.5)
	
	var current_position: Vector2 = first_tile_position
	
	#Then, it calculates each position through its respective logical position
	for pos in logical_board:
		result[pos] = current_position + Vector2(pos.y * tile_size, pos.x * tile_size)
		
	
	return result
	

#This function instantiates and adds the Turn Control Node to the board
func turn_control_initializer() -> void:
	turn_control = turn_control_scene.instantiate()
	add_child(turn_control)
	turn_control.update_turn_ui()
	

#This function instantiates and adds the Tile Scenes to their respective position
func board_tile_placer() -> void:
	for logical_position in logical_board:
		#Firstly, it instantiates the scene and adds it to the board
		var tile: Tile = tile_scene.instantiate()
		add_child(tile)
		
		#Then, it stores the Tile Scene to the Tile Dictionary
		#It's stored with its logical position being the key,
		#so you only need to know that Vector to access the Tile
		tile_dictionary[logical_position] = tile
		
		#Each tile stores its logical position in their own logic and
		#connect the signal of when they're pressed to a function later in this script
		tile.tile_logical_position = logical_position
		tile.tile_pressed.connect(_on_tile_pressed)
		
		#Finally, it adjusts their position and scale
		var initial_tile_size: Vector2 = tile.button.size
		tile.scale *= (tile_size / max(initial_tile_size.x, initial_tile_size.y))
		tile.position = positions_dictionary[logical_position]
	

#TESTING FUNCTION
#Just like how the test characters are being loaded to this scene, this function is temporary
func character_tester_placer() -> void:
	var player_scene = player.instantiate()
	add_child(player_scene)
	var enemy1_scene = enemy_1.instantiate()
	add_child(enemy1_scene)
	var enemy2_scene = enemy_2.instantiate()
	add_child(enemy2_scene)
	
	player_character = player_scene
	character_list.append(player_scene)
	character_list.append(enemy1_scene)
	character_list.append(enemy2_scene)
	
	for index in range(character_list.size()):
		var rand_position: Vector2i = Vector2i(index, randi_range(0, length - 1))
		
		tile_dictionary[rand_position].occupied = true
		tile_dictionary[rand_position].character_in_tile = index
		
		character_list[index].level_index = index
		character_list[index].level_start()
		
		character_list[index].board_position = rand_position
		character_list[index].position = positions_dictionary[rand_position]
		character_list[index].scale *= tile_size/200.0
	

#This function is what controls the turns and its logic
func character_turn() -> void:
	#First, it gets the first character from the character order array
	#This array is calculated in the Turn Control logic
	var current_index: int = turn_control.turn_order.pop_front()
	var current_character: CharacterClass = character_list[current_index]
	
	#Then, it checks if the character in question is a player character or a NPC
	#Either way, it will make that character move, wait for its movement to end,
	#makes their action and wait for that action to be over before
	#that character's turn ends
	if current_character.player_character:
		player_movement(current_character)
		await player_movement_over
		player_action(current_character)
		await player_action_over
	else:
		npc_movement(current_character)
		await npc_movement_over
		npc_action(current_character)
		await npc_action_over
	
	#After a character's turn, it decreases the number of actions left in the turn and
	#proceeds to the next character
	turn_control.turn_actions -= 1
	
	#Then, it emits the new_turn() signal, which starts the next character's turn
	new_turn.emit()
	

#This function starts a character's turn when the new_turn() signal is emitted
func _on_new_turn() -> void:
	#It checks if there's any remaining action in the turn and,
	#if not, it ends the current one and starts a new one
	if turn_control.turn_actions == 0:
		turn_control.turn_end()
		turn_control.turn_start(character_list)
	
	#After continuing or starting the turn, it starts the next character's turn
	character_turn()
	

#This function runs every time a tile is pressed (tile_pressed signal is emitted)
#It takes the arguments that the signal sends, hence why we store some information in each tile
func _on_tile_pressed(tile_lp: Vector2i, character_index: int, can_player_move_here: bool) -> void:
	print(character_index)
	#Runs this code if the player is set to move
	if player_to_move:
		check_player_movement(tile_lp, can_player_move_here)
	

#This function starts and sets up the player's movement
func player_movement(character: CharacterClass) -> void:
	#First it calculates the movement possibilities for the player
	character.movement_calculator(tile_dictionary, height, length)
	
	#Then it sets the possible tiles to be ready for the player's movement
	for tile_position in character.possible_movements:
		var tile: Tile = tile_dictionary[tile_position]
		tile.highlight(tile.movement_highlight)
		tile.player_can_move_here = true
		
	
	#Then, it makes it so that the player can move and waits for the movement to be over
	player_to_move = true
	await player_movement_over
	
	#After the movement is done, it resets the tiles...
	for tile_position in character.possible_movements:
		var tile: Tile = tile_dictionary[tile_position]
		tile.un_highlight()
		tile.player_can_move_here = false
		
	
	#...and also the movement possibilities and stops the player from moving
	character.possible_movements.clear()
	player_to_move = false
	

#This function checks if the player can move to the selected tile
func check_player_movement(tile_position: Vector2i, can_move: bool) -> void:
	#If not, it does nothing (for now, it just prints a message)
	if !can_move:
		print("Player can't move here!")
		
	#If it can, it plays the player's movement and lets all other function know the movement is over
	else:
		update_position(player_character, player_character.board_position, tile_position)
		
		await get_tree().create_timer(randf_range(transition_range[0], transition_range[1])).timeout
		player_movement_over.emit()
	

#This function takes care of the player's action
#Currently, it does nothing, just emits that the action is over
func player_action(character: CharacterClass) -> void:
	print("{0} made an action!".format([character.character_name]))
	
	await get_tree().create_timer(randf_range(transition_range[0], transition_range[1])).timeout
	player_action_over.emit()
	

#This function takes care of the NPC's movement
#Currently, it just chooses a random position from the possible ones
#and then emits the npc_movement_over signal
func npc_movement(character: CharacterClass) -> void:
	character.movement_calculator(tile_dictionary, height, length)
	var next_position_index: int = randi_range(0, character.possible_movements.size() - 1)
	var next_position: Vector2i = character.possible_movements[next_position_index]
	update_position(character, character.board_position, next_position)
	character.possible_movements.clear()
	
	await get_tree().create_timer(randf_range(transition_range[0], transition_range[1])).timeout
	npc_movement_over.emit()
	

#This function takes care of the NPC's action
#Currently it does nothing other than emitting the npc_action_over signal
func npc_action(character: CharacterClass) -> void:
	print("{0} made an action!".format([character.character_name]))
	
	await get_tree().create_timer(randf_range(transition_range[0], transition_range[1])).timeout
	npc_action_over.emit()
	

#This functions moves a character from one position to another
func update_position(character: CharacterClass, current_position: Vector2i, new_position: Vector2i) -> void:
	#Firstly, it resets the character's current position
	tile_dictionary[current_position].occupied = false
	tile_dictionary[current_position].character_in_tile = -1
	
	#Then, it moves the character to the new position
	var movement_timer: float = randf_range(0.2, 0.5)
	var movement_tween: Tween = create_tween()
	movement_tween.tween_property(character, "position", positions_dictionary[new_position], movement_timer)
	movement_tween.set_ease(Tween.EASE_OUT)
	movement_tween.set_trans(Tween.TRANS_LINEAR)
	movement_tween.play()
	await movement_tween.finished
	movement_tween.kill()
	
	#And then, it lets the new position know that the character is there
	character.board_position = new_position
	tile_dictionary[new_position].occupied = true
	tile_dictionary[new_position].character_in_tile = character.level_index
	

#This function runs everytime the npc_action_over signal is emitted
#Currently, it does nothing
func _on_npc_action_over() -> void:
	print("NPC Action Over!")
	

#This function runs everytime the npc_movement_over signal is emitted
#Currently, it does nothing
func _on_npc_movement_over() -> void:
	print("NPC Movement Over!")
	

#This function runs everytime the player_action_over signal is emitted
#Currently, it does nothing
func _on_player_action_over() -> void:
	print("Player Action Over!")
	

#This function runs everytime the player_movement_over signal is emitted
#Currently, it does nothing
func _on_player_movement_over() -> void:
	print("Player Movement Over!")
	
